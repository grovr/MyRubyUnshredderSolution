require 'chunky_png'

class InputImage
  def initialize(filename)
    @png = ChunkyPNG::Image.from_file(filename)
  end

  def width
    return @png.width
  end

  def height
    return @png.height
  end

  def get_pixel_value(x, y)
    return ChunkyPNG::Color.r(@png[x,y]), ChunkyPNG::Color.g(@png[x,y]),
      ChunkyPNG::Color.b(@png[x,y]), ChunkyPNG::Color.a(@png[x,y])
  end

  def swap_pixels(x1, y1, x2, y2)
    first = @png[x1,y1]
    @png[x1,y1] = @png[x2,y2]
    @png[x2,y2] = first
  end

  def save(location)
    @png.save(location)
  end

  def get_pixel(x, y)
    return @png[x, y]
  end

  def write_pixel(x, y, value)
    @png[x, y,] = value
  end
end