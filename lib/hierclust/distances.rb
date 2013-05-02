require 'matrix'

module Hierclust
  # Represents the pair-wise distances between a set of items.
  class Distances
    attr_reader :nearest, :outliers, :separation
    attr_reader :matrix, :nils, :items

    # Create a new Distances for the given +items+
    def initialize(items, nils = nil)
      @items = items.dup
      @separation = 0
      @nearest = []
      @nils = nils
      item_count = items.count
      @matrix = Matrix.zero(items.count, items.count).to_a
      (0..item_count - 1).each do |i|
        (i..item_count - 1).each do |j|
          if j != i
            distance = items[i].distance_to(items[j], nils)
            if distance < @separation || @separation == 0
              @separation = distance
              @nearest = [items[i], items[j]]
            end
            @matrix[i][j] = distance
            @matrix[j][i] = distance
          end
        end
      end
      @outliers = @items - @nearest

      #upper_triangular = Matrix.build(items.count, items.count) do |i,j|
      #  if i < j
      #    distance = items[i].distance_to(items[j], nils)
      #    if distance < @separation || @separation == 0
      #      @separation = distance
      #      @nearest = [items[i], items[j]]
      #    end
      #    distance
      #  else
      #    0
      #  end
      #end
      #
      #@matrix = Matrix.build(items.count,items.count) do |i,j|
      #  if i < j
      #    upper_triangular[i,j]
      #  else
      #    upper_triangular[j,i]
      #  end
      #end
      #
      #while !items.empty?
      #  origin = items.shift
      #  @item_indexes[origin] = index
      #  index += 1
      #
      #  items.each do |other|
      #    distance = origin.distance_to(other, nils)
      #    if @separation == 0 or distance < @separation
      #      @separation = distance
      #      @nearest = [origin, other]
      #    end
      #  end
      #end
    end

    # return the best cluster, updating the matrix and
    # nearest, and outliers
    def pop_next_cluster
      cluster = Cluster.new(nearest)
      ind1 = items.index(nearest[0])
      ind2 = items.index(@nearest[1])

      # yeah....
      delete_first = [ind1,ind2].max
      delete_after = [ind1,ind2].min

      # start slicing and dicing, lets get rid of the old items
      # and add our shiny new cluster
      items.delete_at(delete_first)
      items.delete_at(delete_after)
      items.push(cluster)

      # http://en.wikipedia.org/wiki/Single-linkage_clustering
      # delete the rows for the clustered items, then delete
      # the distances for the items that are getting clustered
      row1 = matrix.delete_at(delete_first)
      row1.delete_at(delete_first)
      row1.delete_at(delete_after)
      row2 = matrix.delete_at(delete_after)
      row2.delete_at(delete_first)
      row2.delete_at(delete_after)

      # figure out the distances for the new cluster to all the
      # remaining points
      new_distances = (0..(row1.count - 1)).collect do |i|
        [row1[i], row2[i]].min
      end
      # new cluster is 0 distance from itself
      new_distances.push(0)

      # remove the distances to the clustered items in
      # each remaining row
      matrix.each_with_index do |row,i|
        row.delete_at(delete_first)
        row.delete_at(delete_after)
        # and add the distance to the new cluster to each remaining row
        row.push(new_distances[i])
      end

      # add the new row for the new cluster
      matrix.push(new_distances)

      # find the next cluster. This could be done more efficiently...
      @separation = 0
      matrix.each_with_index do |row,i|
        row.each_with_index do |distance,j|
          if i != j
            if distance < separation || separation == 0
              @separation = distance
              @nearest = [items[i], items[j]]
            end
          end
        end
      end

      @outliers = @items - @nearest
      cluster
    end

=begin

old idea

1 calculate all distances
2 update distances when a new cluster is created from two existing points
3 keep distances sorted by separation so that we always know which is shortest

new idea

don't worry about the lower level clusters
don't worry about the higher level clusters
just form clusters of the desired separation
start by dividing the points into a grid of 0.5 * sep
and put all points in the same grid cells together
...
and then do regular hierarchical clustering! we should be fine at that point.
sweet....

=end

  end
end