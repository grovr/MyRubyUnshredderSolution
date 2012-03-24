require_relative 'OutputImage.rb'
require_relative 'InputImage.rb'
require_relative 'UnderThresholdColumnComparisonStrategy'

class InstagramChallenge
  def initialize()
    @image = InputImage.new("challenge.png")
    @outputLocation = "output.png"
  end

  def set_input_image(location)
    @image = InputImage.new location
  end

  def perform_unshredding()
    calculate_columns()
    columnDiffs = diff_all_columns()
    order = get_order_of_columns(columnDiffs)
    create_new_image()
    write_correct_image_to_output(order)
    save_output_image()
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
  
  def diff_left_against_other_columns(leftColumn)
    diffs = []
    columnComparisonStrategy = UnderThresholdColumnComparisonStrategy.new
    @rightXs.each do |rightColumn|
      diffs.push(columnComparisonStrategy.compute_difference(@image, leftColumn, rightColumn))
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
      minOfArray = [minOfArray, diff].min if index != oneDIndex
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

chall = InstagramChallenge.new
chall.perform_unshredding()
