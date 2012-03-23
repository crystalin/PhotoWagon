# encoding: utf-8
class ImageUploader < CarrierWave::Uploader::Base

  include CarrierWave::MiniMagick

  storage :file

  IMAGE_SIZES = {
      :full_page => [1600, 1600],
      :front_page => [300, 168],
      :cover => [972, 240]
  }

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  version :full_page do
    process :resize_to_fit => IMAGE_SIZES[:full_page]
    process :quality => 80
  end

  version :front_page do
    process :manual_crop => :front
    process :resize_to_fill => IMAGE_SIZES[:front_page]
    process :quality => 80
  end

  version :cover do
    process :manual_crop => :cover
    process :resize_to_fill => IMAGE_SIZES[:cover]
    process :quality => 80
  end

  def extension_white_list
     %w(jpg jpeg)
  end

  def manual_crop(thumb)
    manipulate! do |img|
      if thumb == :cover
        img.crop "#{model.crop_cover_w}x#{model.crop_cover_h}+#{model.crop_cover_x}+#{model.crop_cover_y}"
      else
        img.crop "#{model.crop_front_w}x#{model.crop_front_h}+#{model.crop_front_x}+#{model.crop_front_y}"
      end
      img
    end
  end

end
