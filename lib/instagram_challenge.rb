require_relative 'OutputImage.rb'
require_relative 'InputImage.rb'

class InstagramChallenge
  def initialize(filename)
    @image = InputImage.new filename
    @outputLocation = "rearranged.png"
  end

  def set_output_location(location)
    @outputLocation = location
  end

  def calculate_columns()
    calculate_column_widths()
    calculate_columns_from_widths(@columnWidths)
  end

  def calculate_column_widths()
    @columnWidths = Array.new(20, 32)
  end

  def calculate_columns_from_widths(columnWidths)
    @leftXs = []
    @rightXs = []
    leftX = 0
    rightX = -1
    columnWidths.each do |width|
      @leftXs.push(leftX)
      leftX += width
      rightX += width
      @rightXs.push(rightX)
    end
  end

  def rearrange
    @image.save @outputLocation
  end

  def swap_columns(first, second)
    (0...@image.height).each do |y|
      @image.swap_pixels(first, y, second, y)
    end
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

  def diff_columns(x1, x2)
    diff = 0
    (0...@image.height).each do |y|
      diff += diff_pixels(x1, y, x2, y)
    end
    return diff
  end

  def average_of_2_diff_columns(x1, x2)
    diff = 0
    (0...(@image.height - 1)).each do |y|
      diff += diff_pixels(x1, y, x2, y)
    end
    return diff
  end

  def average_of_2_diff_pixels(x1, y1, x2, y2)
    first1 = @image.get_pixel_value(x1, y1)
    first2 = @image.get_pixel_value(x1 + 1, y1)
    firstAverage = average_2_pixels_values(first1, first2)
    second1 = @image.get_pixel_value(x2, y2)
    second2 = @image.get_pixel_value(x2 + 1, y2)
    secondAverage = average_2_pixels_values(second1, second2)
    diff = 0
    (0...firstAverage.length).each do |index|
      diff += (firstAverage[index] - secondAverage[index]).abs
    end
    return diff
  end

  def average_2_pixels_values(value1, value2)
    averageValue = []
    (0..value1.length).each do |index|
      averageValue.push((value1[index] + value2[index]) / 2)
    end
    return averageValue
  end

  def smooth_changed_diff_columns(left, right)
    diff = 0
    (0...@image.height).each do |y|
      diff += smooth_changed_diff_pixels(left, y, right, y)
    end
    return diff
  end

  def smooth_changed_diff_pixels(left, y1, right, y2)
    leftChange = diff_pixels(left, y1, left+1, y1)
    rightToLeftChange = diff_pixels(left, y1, right, y2)
    return (leftChange - rightToLeftChange).abs
  end

  def under_threshold_diff_columns(left, right)
    diff = 0
    (0...@image.height).each do |y|
      diff += under_threshold_diff_pixels(left, y, right, y)
    end
    return diff
  end

  def under_threshold_diff_pixels(left, y1, right, y2)
    if (diff_pixels(left, y1, right, y2) < 30)
      return 0
    else
      return 1
    end
  end


  def diff_left_against_other_columns(leftColumn)
    diffs = []
    @rightXs.each do |rightColumn|
      #diffs.push(diff_columns(leftColumn, rightColumn))
      #diffs.push(average_of_2_diff_columns(leftColumn, rightColumn))
      #diffs.push(smooth_changed_diff_columns(leftColumn, rightColumn))
      diffs.push(under_threshold_diff_columns(leftColumn, rightColumn))
    end
    return diffs
  end

  # Returns Array containing an element for each left column where the element is
  # an array of values of that column compared against all right columns
  def diff_all_columns()
    diffs = []
    @leftXs.each do |leftColumn|
      diffs.push(diff_left_against_other_columns(leftColumn))
    end
    return diffs
  end

  def pretty_print_2d_array(array)
    puts "["
    array.each_index do |yIndex|
      lineString = yIndex.to_s() + "["
      array[yIndex].each_index do |xIndex|
        lineString += array[yIndex][xIndex].to_s + ","
      end
      lineString += "]"
      puts lineString
    end
    puts "]"
  end

  def find_index_of_smallest_non_negative_number(array)
    minIndex = -1
    minValue = -1
    array.each_index do |index|
      value = array[index]
      if (value > -1)
        if (minValue == -1 || value < minValue)
          minIndex = index
          minValue = value
        end
      end
    end
    return minIndex
  end

  def index_of_row_with_largest_minimum(twoDArray)
    largestMinimum = -1000000
    largestIndex = -1;
    twoDArray.each_with_index do | oneDArray, index|
      minOfArray = 10000000
      oneDArray.each_with_index do | diff, oneDIndex |
        if (index != oneDIndex)
          minOfArray = [minOfArray, diff].min
        end
      end
      if (largestMinimum < minOfArray)
        largestMinimum = minOfArray
        largestIndex = index
      end
    end
    return largestIndex
  end

  def detect_left_column_of_image(twoDArray)
    return index_of_row_with_largest_minimum(twoDArray)
  end

  def index_of_best_left_hand_column_for_right_hand_column(rhcIndex, twoDArray, excludedIndices)
    smallestDiff = 1000000000
    smallestIndex = -1
    twoDArray.each_with_index do |oneDArray, index|
      if (index != rhcIndex && !excludedIndices.include?(index))
        diff = oneDArray[rhcIndex]
        if (diff <  smallestDiff)
          smallestDiff = diff
          smallestIndex = index
        end
      end
    end
    return smallestIndex
  end

  def get_order_of_columns(twoDArray)
    order = []
    leftCol = detect_left_column_of_image(twoDArray)
    order << leftCol
    (1..twoDArray.length - 1).each do |index|
      leftCol = index_of_best_left_hand_column_for_right_hand_column(leftCol, twoDArray, order)
      order << leftCol
    end
    return order
  end

  def create_new_image()
    @outputImage = OutputImage.new(@image.width(), @image.height())
  end

  def write_correct_image_to_output(orderOfColumns)
    outputX = 0
    orderOfColumns.each do | columnFromOrig |
      copy_section_from_input_to_output(columnFromOrig, outputX)
      outputX += @columnWidths[columnFromOrig]
    end
  end

  def save_output_image()
    @outputImage.save(@outputLocation)
  end

  def copy_column_from_input_to_output(inputX, outputX)
    (0...@image.height).each do |y|
      @outputImage.write_pixel(outputX, y, @image.get_pixel(inputX, y))
    end
  end

  def copy_section_from_input_to_output(inputSection, outputStartingX)
    (0...@columnWidths[inputSection]).each do |x|
      copy_column_from_input_to_output(@leftXs[inputSection] + x, outputStartingX + x)
    end
  end

  #TODO need columnWidths to be set
end

chall = InstagramChallenge.new("./challenge.png")
chall.set_output_location("./output.png")
chall.calculate_columns()
columnDiffs = chall.diff_all_columns()
order = chall.get_order_of_columns(columnDiffs)
chall.create_new_image()
chall.write_correct_image_to_output(order)
chall.save_output_image()
