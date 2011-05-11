class Post < ActiveRecord::Base
  attr_accessible :image
  mount_uploader :image, ImageUploader

  scope :last, order('id desc')
  scope :recent, order('published_on desc')
  scope :story, order('published_on asc')

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

  def previous_post
    @previous_post||= self.class.first(:conditions => ["published_on < ?", published_on], :order => "published_on desc")
  end

  def next_post
    @next_post||= self.class.first(:conditions => ["published_on > ?", published_on], :order => "published_on asc")
  end

end
