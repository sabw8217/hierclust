require 'matrix'

module Hierclust
  # Represents the pair-wise distances between a set of items.
  class Distances
    attr_reader :nearest, :outliers, :separation
    attr_reader :matrix, :item_indexes

    # Create a new Distances for the given +items+
    def initialize(items, nils = nil)
      @items = items
      @separation = 0
      @nearest = []
      @item_indexes = {}
      index = 0
      items = @items.dup
      upper_triangular = Matrix.build(items.count, items.count) do |i,j|
        if i < j
          distance = items[i].distance_to(items[j], nils)
          if distance < @separation
            @separation = distance
            @nearest = [items[i], items[j]]
          end
        else
          0
        end
      end

      @matrix = Matrix.build(items.count,items.count) do |i,j|
        if i < j
          upper_triangular[i,j]
        else
          upper_triangular[j,i]
        end
      end
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
      @outliers = @items - @nearest
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