require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

module Hierclust
  describe Distances, " with two points" do
    before do
      @x_1, @x_2 = 1, 5
      @y_1, @y_2 = 2, 8
      @p_1 = Point.new(@x_1, @y_1)
      @p_2 = Point.new(@x_2, @y_2)
      @d = Distances.new([@p_1, @p_2])
      @dist = Math.sqrt((@x_1 - @x_2) ** 2 + (@y_1 - @y_2) ** 2)
    end

    it "should have separation equal to distance between those points" do
      @d.separation.should == @dist
    end

    it "should have a two-by-two matrix" do
      @d.matrix.count.should == 2
      @d.matrix[0].count.should == 2
    end

    it "should have zeros on the diagonal" do
      @d.matrix[0][0].should  == 0
      @d.matrix[1][1].should  == 0
    end

    it "should have the distance between the points in the corners" do
      @d.matrix[0][1].should  == @dist
      @d.matrix[1][0].should  == @dist
    end
  end

  describe Distances, " with three points" do
    before do
      @x_1, @x_2, @x_3 = 1, 5, 3
      @y_1, @y_2, @y_3 = 2, 8, 4
      @p_1 = Point.new(@x_1, @y_1)
      @p_2 = Point.new(@x_2, @y_2)
      @p_3 = Point.new(@x_3, @y_3)
      @d = Distances.new([@p_1, @p_2, @p_3])
      @dist_1_2 = Math.sqrt((@x_1 - @x_2) ** 2 + (@y_1 - @y_2) ** 2)
      @dist_2_3 = Math.sqrt((@x_2 - @x_3) ** 2 + (@y_2 - @y_3) ** 2)
      @dist_3_1 = Math.sqrt((@x_3 - @x_1) ** 2 + (@y_3 - @y_1) ** 2)

      x_avg_1_3 = 2
      y_avg_1_3 = 3
      @dist_avg_2 = Math.sqrt((x_avg_1_3 - @x_2) ** 2 + (y_avg_1_3 - @y_2) ** 2)
    end

    it "should tell us the nearest points" do
      @d.nearest.should include(@p_1, @p_3)
    end

    it "should tell us the outliers" do
      @d.outliers.should == [@p_2]
    end

    it "should have separation equal to distance between nearest points" do
      @d.separation.should == @dist_3_1
    end

    it "should have a 3x3 matrix" do
      @d.matrix.count.should == 3
      @d.matrix.each do |row|
        row.count.should == 3
      end
    end

    it "should have zeros on the diagonal" do
      (0..2).each do |n|
        @d.matrix[n][n].should == 0
      end
    end

    it "should have the distances in the matrix" do
      @d.matrix[1][0].should == @dist_1_2
      @d.matrix[2][0].should == @dist_3_1
      @d.matrix[0][1].should == @dist_1_2
      @d.matrix[0][2].should == @dist_3_1
      @d.matrix[1][2].should == @dist_2_3
      @d.matrix[2][1].should == @dist_2_3
    end

    # TODO refactor before do into shared group then split this up
    # into whole other set of tests
    it "should update the matrix after pop_nearest" do
      nearest = @d.pop_next_cluster

      @d.matrix.count.should == 2
      @d.matrix.each do |row|
        row.count.should == 2
      end

      (0..1).each do |n|
        @d.matrix[n][n].should == 0
      end

      @d.nearest.should include(nearest, @p_2)
      @d.separation.should == @d.matrix[1][0]
    end
  end
end