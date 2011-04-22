class Post < ActiveRecord::Base
  attr_accessible :image
  mount_uploader :image, ImageUploader

  before_save :read_information
  has_many :comments

  def read_information
    @information = nil
    if image != nil
      self.title = information['Headline'] || 'No title'
      self.body = information['Caption-Abstract'] || 'No Legend'
      self.published_on = information['DateTimeOriginal'] || information['CreateDate'] ||Time.now
#      puts "#{information['DateTimeOriginal'].class.name} : #{information['DateTimeOriginal']}"
    end
  end

  def information
    @information ||= MiniExiftool.new image.current_path
  end
end
