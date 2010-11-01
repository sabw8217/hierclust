require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

module Hierclust
  describe Cluster, " with no points" do
    before do
      @c = Cluster.new([])
    end

    it "should have nil x-coordinate" do
      @c.coordinates.should be_nil
    end

    it "should have nil radius" do
      @c.radius.should be_nil
    end
  end

  describe Cluster, " with one point" do
    before do
      @x = 123
      @y = 234
      @p = Point.new(@x, @y)
      @c = Cluster.new([@p])
    end

    it "should have the same coordinates as the point" do
      @c.coordinates.should == @p.coordinates
    end

    it "should have the same coordinates as used to create the point" do
      @c.coordinates.should == [@x, @y]
    end

    it "should have 0 radius" do
      @c.radius.should == 0
    end
  end

  describe Cluster, " with two points" do
    before do
      @x_1, @x_2 = 5, 15
      @y_1, @y_2 = 4, 8
      @p_1 = Point.new(@x_1, @y_1)
      @p_2 = Point.new(@x_2, @y_2)
      @c = Cluster.new([@p_1, @p_2])
      @points = @c.points
    end

    it "should have coordinates at the average of points' coordinates" do
      @c.coordinates.should == [10, 6]
    end

    it "should have two points" do
      @points.size.should == 2
    end

    it "should include both points" do
      @points.should include(@p_1, @p_2)
    end

    it "should have correct radius" do
      radius = Math.sqrt((@x_1 - @x_2) ** 2 + (@y_1 - @y_2) ** 2) / 2.0
      @c.radius.should == radius
    end
  end

  describe Cluster, " with one point and one cluster" do
    before do
      @x_1, @x_2, @x_3 = 1, 2, 3
      @y_1, @y_2, @y_3 = 2, 2, 5
      @p_1 = Point.new(@x_1, @y_1)
      @p_2 = Point.new(@x_2, @y_2)
      @p_3 = Point.new(@x_3, @y_3)
      @c_1 = Cluster.new([@p_1, @p_2])
      @c_2 = Cluster.new([@p_3, @c_1])
    end

    it "should have two items" do
      @c_2.items.size.should == 2
    end

    it "should have three points" do
      @c_2.points.size.should == 3
    end

    it "should have coordinates at the average of points' coordinates" do
      @c_2.coordinates.should == [2, 3]
    end
  end
end