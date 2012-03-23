
class ColumnComparisonStrategy
  def computeDifference(image, leftColumn, rightColumn)
  end

  def diff_pixels(x1, y1, x2, y2)
    first = @image.get_pixel_value(x1, y1)
    second = @image.get_pixel_value(x2, y2)
    diff = 0
    (0...first.length).each do |index|
      diff += (first[index] - second[index]).abs
    end
    return diff
  end
end
