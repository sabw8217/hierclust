module Hierclust
  # A Point represents a single point in n-dimensional space.
  class Point
    # x-coordinate
    attr_accessor :coordinates
    attr_accessor :data
    
    # Create a new Point with the given coordinates.
    def initialize(*coordinates)
      @data = coordinates.last.is_a?(Hash) ? coordinates.pop : {}
      @coordinates = coordinates.flatten
    end
    
    # Returns this distance from this Point to an +other+ Point.
    def distance_to(other)
      sum_of_squares = coordinates.zip(other.coordinates).map do |point, other_point|
        (other_point - point) ** 2
      end.inject(0) {|sum, distance| sum + distance }
      Math.sqrt(sum_of_squares)
    end
    
    # Simplifies code by letting us treat Clusters and Points interchangeably
    def size #:nodoc:
      1
    end
    
    # Simplifies code by letting us treat Clusters and Points interchangeably
    def radius #:nodoc:
      0
    end
    
    # Simplifies code by letting us treat Clusters and Points interchangeably
    def points #:nodoc:
      [self]
    end
    
    # Returns a legible representation of this Point.
    def to_s
      "(#{coordinates.join(', ')})"
    end
    
    # Sorts points relative to each other on the x-axis.
    # 
    # Uses y-axis as a tie-breaker, so that sorting is stable even if
    # multiple points have the same x-coordinate.
    # 
    # Uses object_id as a final tie-breaker, so sorts are guaranteed to
    # be stable even when multiple points have the same coordinates.
    def <=>(other)
      cmp = coordinates <=> other.coordinates
      cmp = object_id <=> other.object_id if cmp == 0
      cmp
    end
  end
end