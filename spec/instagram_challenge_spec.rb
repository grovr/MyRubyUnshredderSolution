# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'instagram_challenge'
require 'chunky_png'

describe InstagramChallenge do

  before(:each) do
    @instagramChallenge = InstagramChallenge.new "./test.png"
  end

  it "should have a setOutputLocation function to set the output location" do
    @instagramChallenge.setOutputLocation("./output.png")
  end

  it "should have a function to invoke rearranging the photo" do
    @instagramChallenge.rearrange
  end

  it "should write to the output file in rearrange" do
    outputFileName = "./output.png"
    if File.exists?(outputFileName)
      File.delete(outputFileName)
    end
    @instagramChallenge.setOutputLocation(outputFileName)
    @instagramChallenge.rearrange
    File.exists?(outputFileName).should be_true
  end

  it "should be able to swap 2 columns of it's image" do
    @instagramChallenge.swapColumns(0, 9)
    (0...5).each do |y|
      @instagramChallenge.instance_variable_get(:@image).getPixelValue(0, y).should ==([255, 0, 255, 255])
      @instagramChallenge.instance_variable_get(:@image).getPixelValue(9, y).should ==([0, 255, 255, 255])
    end
  end

    it "should be able to diff 2 pixels" do
    @instagramChallenge.diffPixels(0, 0, 9, 4).should ==(255 + 255)
    @instagramChallenge.diffPixels(0, 0, 0, 1).should ==(0)
  end

  it "should be able to diff 2 columns" do
    @instagramChallenge.diffColumns(0, 9).should == (5*(255+255))
    @instagramChallenge.diffColumns(0, 1).should == (0)
  end

  it "should be able to diff a column against all others as defined by column widths" do
    @instagramChallenge.calculateColumnsFromWidths([5,5])
    firstLeft = @instagramChallenge.instance_variable_get(:@leftXs)[0]
    @instagramChallenge.diffLeftAgainstOtherColumns(firstLeft).should ==([0, 5])
  end

  it "should be able to diff all lefts against all rights" do
    @instagramChallenge.calculateColumnsFromWidths([5,5])
    @instagramChallenge.diffAllColumns.should ==([[0, 5], [5, 0]])
  end

  it "should be able to calculate left and right x's based on column widths" do
    columnWidth1 = 5
    columnWidth2 = 10
    @instagramChallenge.calculateColumnsFromWidths([columnWidth1, columnWidth2])
    @instagramChallenge.instance_variable_get(:@leftXs).should ==([0, columnWidth1])
    @instagramChallenge.instance_variable_get(:@rightXs).should ==([columnWidth1-1, columnWidth1-1+columnWidth2])
  end

  it "should be able to find the smallest non-neg number in an array" do
    @instagramChallenge.findIndexOfSmallestNonNegativeNumber([-1, -1, 4, 5, 2]).should ==(4)
    @instagramChallenge.findIndexOfSmallestNonNegativeNumber([5, -1]).should ==(0)
  end

  it "should be able to find the largest minimum row" do
    @instagramChallenge.indexOfRowWithLargestMinimum([[3, 4], [2, 5]]).should == (0)
    @instagramChallenge.indexOfRowWithLargestMinimum([[1, 4], [2, 5]]).should == (0)
  end

  it "should be able to select the best LHC to match a RHC" do
    @instagramChallenge.indexOfBestLHCForRHC(0, [[3, 4], [2, 5]], []).should == (1)
    @instagramChallenge.indexOfBestLHCForRHC(0, [[3, 4, 5], [2, 5, 6], [1, 8, 9]], []).should == (2)
  end

  it "should be able to generate a correct order of columns" do
    @instagramChallenge.getOrderOfColumns([[3,4], [2,5]]).should ==([0,1])
    @instagramChallenge.getOrderOfColumns([[333,2], [4,555]]).should ==([1,0])
    @instagramChallenge.getOrderOfColumns([[333, 4, 5], [2, 555, 6], [1, 8, 999]]).should == ([0,2,1])
    @instagramChallenge.getOrderOfColumns([[333, 6, 2], [1, 555, 9], [7, 7, 999]]).should == ([2,0,1])
  end
end

describe InputImage do
  before(:each) do
    @image = InputImage.new "./test.png"
  end

  it "should have a width function" do
    @image.width()
  end

  it "should return the width of the image" do
    @image.width().should equal(10)
  end

  it "should be able to get the height of the image" do
    @image.height().should equal(5)
  end

  it "should be able to get the rgba values from a pixel" do
    @image.getPixelValue(0,0).should ==([0, 255, 255, 255])
    @image.getPixelValue(9,4).should ==([255, 0, 255, 255])
  end

  it "should be able to swap pixels" do
    @image.swapPixels(0, 0, 9, 4)
    @image.getPixelValue(0, 0).should ==([255, 0, 255, 255])
    @image.getPixelValue(9, 4).should ==([0, 255, 255, 255])
  end

  it "should save to  defined location" do
    outputFileName = "./output.png"
    if File.exists?(outputFileName)
      File.delete(outputFileName)
    end
    @image.save(outputFileName);
    File.exists?(outputFileName).should be_true
  end
end