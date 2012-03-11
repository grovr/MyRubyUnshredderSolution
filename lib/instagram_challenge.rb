require_relative 'OutputImage.rb'
require_relative 'InputImage.rb'

class InstagramChallenge
  def initialize(filename)
    @image = InputImage.new filename
    @outputLocation = "rearranged.png"
  end

  def setOutputLocation(location)
    @outputLocation = location
  end

  def calculateColumns()
    calculateColumnWidths()
    calculateColumnsFromWidths(@columnWidths)
  end

  def calculateColumnWidths()
    @columnWidths = Array.new(20, 32)
  end

  def calculateColumnsFromWidths(columnWidths)
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

  def swapColumns(first, second)
    (0...@image.height).each do |y|
      @image.swapPixels(first, y, second, y)
    end
  end

  def diffPixels(x1, y1, x2, y2)
    first = @image.getPixelValue(x1, y1)
    second = @image.getPixelValue(x2, y2)
    diff = 0
    (0...first.length).each do |index|
      diff += (first[index] - second[index]).abs
    end
    return diff
  end

  def diffColumns(x1, x2)
    diff = 0
    (0...@image.height).each do |y|
      diff += diffPixels(x1, y, x2, y)
    end
    return diff
  end

  def averageOf2DiffColumns(x1, x2)
    diff = 0
    (0...(@image.height - 1)).each do |y|
      diff += diffPixels(x1, y, x2, y)
    end
    return diff
  end

  def averageOf2DiffPixels(x1, y1, x2, y2)
    first1 = @image.getPixelValue(x1, y1)
    first2 = @image.getPixelValue(x1 + 1, y1)
    firstAverage = average2PixelValues(first1, first2)
    second1 = @image.getPixelValue(x2, y2)
    second2 = @image.getPixelValue(x2 + 1, y2)
    secondAverage = average2PixelValues(second1, second2)
    diff = 0
    (0...firstAverage.length).each do |index|
      diff += (firstAverage[index] - secondAverage[index]).abs
    end
    return diff
  end

  def average2PixelValues(value1, value2)
    averageValue = []
    (0..value1.length).each do |index|
      averageValue.push((value1[index] + value2[index]) / 2)
    end
    return averageValue
  end

  def smoothChangeDiffColumns(left, right)
    diff = 0
    (0...@image.height).each do |y|
      diff += smoothChangeDiffPixels(left, y, right, y)
    end
    return diff
  end

  def smoothChangeDiffPixels(left, y1, right, y2)
    leftChange = diffPixels(left, y1, left+1, y1)
    rightToLeftChange = diffPixels(left, y1, right, y2)
    return (leftChange - rightToLeftChange).abs
  end

  def underThresholdDiffColumns(left, right)
    diff = 0
    (0...@image.height).each do |y|
      diff += underThresholdDiffPixels(left, y, right, y)
    end
    return diff
  end

  def underThresholdDiffPixels(left, y1, right, y2)
    if (diffPixels(left, y1, right, y2) < 30)
      return 0
    else
      return 1
    end
  end


  def diffLeftAgainstOtherColumns(leftColumn)
    diffs = []
    @rightXs.each do |rightColumn|
      #diffs.push(diffColumns(leftColumn, rightColumn))
      #diffs.push(averageOf2DiffColumns(leftColumn, rightColumn))
      #diffs.push(smoothChangeDiffColumns(leftColumn, rightColumn))
      diffs.push(underThresholdDiffColumns(leftColumn, rightColumn))
    end
    return diffs
  end

  # Returns Array containing an element for each left column where the element is
  # an array of values of that column compared against all right columns
  def diffAllColumns()
    diffs = []
    @leftXs.each do |leftColumn|
      diffs.push(diffLeftAgainstOtherColumns(leftColumn))
    end
    return diffs
  end

  def prettyPrint2DArray(array)
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

  def findIndexOfSmallestNonNegativeNumber(array)
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

  def indexOfRowWithLargestMinimum(twoDArray)
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

  def detectLeftColumnOfImage(twoDArray)
    return indexOfRowWithLargestMinimum(twoDArray)
  end

  def indexOfBestLHCForRHC(rhcIndex, twoDArray, excludedIndices)
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

  def getOrderOfColumns(twoDArray)
    order = []
    leftCol = detectLeftColumnOfImage(twoDArray)
    order << leftCol
    (1..twoDArray.length - 1).each do |index|
      leftCol = indexOfBestLHCForRHC(leftCol, twoDArray, order)
      order << leftCol
    end
    return order
  end

  def createNewImage()
    @outputImage = OutputImage.new(@image.width(), @image.height())
  end

  def writeCorrectImageToOutput(orderOfColumns)
    outputX = 0
    orderOfColumns.each do | columnFromOrig |
      copySectionFromInputToOutput(columnFromOrig, outputX)
      outputX += @columnWidths[columnFromOrig]
    end
  end

  def saveOutputImage()
    @outputImage.save(@outputLocation)
  end

  def copyColumnFromInputToOutput(inputX, outputX)
    (0...@image.height).each do |y|
      @outputImage.writePixel(outputX, y, @image.getPixel(inputX, y))
    end
  end

  def copySectionFromInputToOutput(inputSection, outputStartingX)
    (0...@columnWidths[inputSection]).each do |x|
      copyColumnFromInputToOutput(@leftXs[inputSection] + x, outputStartingX + x)
    end
  end

  #TODO need columnWidths to be set
end

chall = InstagramChallenge.new("./challenge.png")
chall.setOutputLocation("./output.png")
chall.calculateColumns()
columnDiffs = chall.diffAllColumns()
order = chall.getOrderOfColumns(columnDiffs)
chall.createNewImage()
chall.writeCorrectImageToOutput(order)
chall.saveOutputImage()
