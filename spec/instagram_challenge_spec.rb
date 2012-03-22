# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'instagram_challenge'
require 'chunky_png'

describe InstagramChallenge do

  before(:each) do ||
    @instagramChallenge = InstagramChallenge.new
    @instagramChallenge.set_input_image("./test.png")
  end

  it "should have a set_output_location function to set the output location" do
    @instagramChallenge.set_output_location("./output.png")
  end

  it "should have a function to invoke rearranging the photo" do
    @instagramChallenge.rearrange
  end

  it "should write to the output file in rearrange" do
    outputFileName = "./output.png"
    if File.exists?(outputFileName)
      File.delete(outputFileName)
    end
    @instagramChallenge.set_output_location(outputFileName)
    @instagramChallenge.rearrange
    File.exists?(outputFileName).should be_true
  end

  it "should be able to swap 2 columns of it's image" do
    @instagramChallenge.swap_columns(0, 9)
    (0...5).each do |y|
      @instagramChallenge.instance_variable_get(:@image).get_pixel_value(0, y).should ==([255, 0, 255, 255])
      @instagramChallenge.instance_variable_get(:@image).get_pixel_value(9, y).should ==([0, 255, 255, 255])
    end
  end

    it "should be able to diff 2 pixels" do
    @instagramChallenge.diff_pixels(0, 0, 9, 4).should ==(255 + 255)
    @instagramChallenge.diff_pixels(0, 0, 0, 1).should ==(0)
  end

  it "should be able to diff 2 columns" do
    @instagramChallenge.diff_columns(0, 9).should == (5*(255+255))
    @instagramChallenge.diff_columns(0, 1).should == (0)
  end

  it "should be able to diff a column against all others as defined by column widths" do
    @instagramChallenge.calculate_columns_from_widths([5,5])
    firstLeft = @instagramChallenge.instance_variable_get(:@leftXs)[0]
    @instagramChallenge.diff_left_against_other_columns(firstLeft).should ==([0, 5])
  end

  it "should be able to diff all lefts against all rights" do
    @instagramChallenge.calculate_columns_from_widths([5,5])
    @instagramChallenge.diff_all_columns.should ==([[0, 5], [5, 0]])
  end

  it "should be able to calculate left and right x's based on column widths" do
    columnWidth1 = 5
    columnWidth2 = 10
    @instagramChallenge.calculate_columns_from_widths([columnWidth1, columnWidth2])
    @instagramChallenge.instance_variable_get(:@leftXs).should ==([0, columnWidth1])
    @instagramChallenge.instance_variable_get(:@rightXs).should ==([columnWidth1-1, columnWidth1-1+columnWidth2])
  end

  it "should be able to find the smallest non-neg number in an array" do
    @instagramChallenge.find_index_of_smallest_non_negative_number([-1, -1, 4, 5, 2]).should ==(4)
    @instagramChallenge.find_index_of_smallest_non_negative_number([5, -1]).should ==(0)
  end

  it "should be able to find the largest minimum row" do
    @instagramChallenge.index_of_row_with_largest_minimum([[3, 4], [2, 5]]).should == (0)
    @instagramChallenge.index_of_row_with_largest_minimum([[1, 4], [2, 5]]).should == (0)
  end

  it "should be able to select the best LHC to match a RHC" do
    @instagramChallenge.index_of_best_left_hand_column_for_right_hand_column(0, [[3, 4], [2, 5]], []).should == (1)
    @instagramChallenge.index_of_best_left_hand_column_for_right_hand_column(0, [[3, 4, 5], [2, 5, 6], [1, 8, 9]], []).should == (2)
  end

  it "should be able to generate a correct order of columns" do
    @instagramChallenge.get_order_of_columns([[3,4], [2,5]]).should ==([0,1])
    @instagramChallenge.get_order_of_columns([[333,2], [4,555]]).should ==([1,0])
    @instagramChallenge.get_order_of_columns([[333, 4, 5], [2, 555, 6], [1, 8, 999]]).should == ([0,2,1])
    @instagramChallenge.get_order_of_columns([[333, 6, 2], [1, 555, 9], [7, 7, 999]]).should == ([2,0,1])
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
    @image.get_pixel_value(0,0).should ==([0, 255, 255, 255])
    @image.get_pixel_value(9,4).should ==([255, 0, 255, 255])
  end

  it "should be able to swap pixels" do
    @image.swap_pixels(0, 0, 9, 4)
    @image.get_pixel_value(0, 0).should ==([255, 0, 255, 255])
    @image.get_pixel_value(9, 4).should ==([0, 255, 255, 255])
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