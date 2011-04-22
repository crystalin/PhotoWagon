# encoding: utf-8

class ImageUploader < CarrierWave::Uploader::Base

  # Include RMagick or ImageScience support:
  include CarrierWave::RMagick
  # include CarrierWave::ImageScience

  # Choose what kind of storage to use for this uploader:
  storage :file
  # storage :s3

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # endcreate_versions_queue

  def resize_to_fill_queue(width, height)
    Stalker.enqueue("image.resize", :image_id => original_filename, :width => width, :height => height)
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

  # Create different versions of your uploaded files:
  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
     %w(jpg jpeg)
  end

  # Override the filename of the uploaded files:
  # def filename
  #   "something.jpg" if original_filename
  # end

end
