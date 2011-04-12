require File.expand_path("../environment", __FILE__)

job "image.resize" do |args|
  image = args['image']
  width = args['width']
  height = args['height']

  image.resize_to_fill(width,height)
end