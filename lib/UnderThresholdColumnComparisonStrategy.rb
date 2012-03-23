require_relative "ColumnComparisonStrategy.rb"
require_relative 'InputImage.rb'

class UnderThresholdColumnComparisonStrategy < ColumnComparisonStrategy
  def computeDifference(image, leftColumn, rightColumn)
    @image = image
    diff = 0
    (0...@image.height).each do |y|
      diff += are_pixels_different_enough(leftColumn, y, rightColumn, y)
    end
    return diff
  end

  def are_pixels_different_enough(left, y1, right, y2)
    if (diff_pixels(left, y1, right, y2) < 30)
      return 0
    else
      return 1
    end
  end
end
