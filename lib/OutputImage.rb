require 'chunky_png'

class OutputImage
  def initialize(width, height)
    @png = ChunkyPNG::Image.new(width, height)
  end

  def save(location)
    @png.save(location)
  end

  def write_pixel(x, y, value)
    @png[x, y,] = value
  end
end