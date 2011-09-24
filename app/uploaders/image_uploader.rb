# encoding: utf-8
class ImageUploader < CarrierWave::Uploader::Base

  include CarrierWave::MiniMagick

  storage :file

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  version :full_page do
    process :resize_to_fit => [1600, 1600]
    process :quality => 80
  end

  version :front_page do
    process :resize_to_fill => [300, 168]
    process :quality => 80
  end

  version :cover do
    process :resize_to_fill => [972, 240]
    process :quality => 80
  end

  def extension_white_list
     %w(jpg jpeg)
  end

end
