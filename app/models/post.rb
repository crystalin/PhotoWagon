class Post < ActiveRecord::Base
  attr_accessible :image, :site_name
  mount_uploader :image, ImageUploader

  scope :latest, order('id desc')
  scope :recent, order('published_on desc')
  scope :story, order('published_on asc')
  scope :on_site, lambda {|site_name| where("site_name = ?",site_name) if site_name}

  before_save :read_information
  has_many :comments

  def read_information
    @information = nil
    if image != nil
      self.title = information['Headline'] || information['Title'] || 'No title'
      self.body = information['Caption-Abstract'] || information['ImageDescription'] || 'No Legend'
      self.published_on = information['DateTimeOriginal'] || information['CreateDate'] ||Time.now
#      puts "#{information['DateTimeOriginal'].class.name} : #{information['DateTimeOriginal']}"
    end
  end

  def information
    @information ||= MiniExiftool.new image.current_path
  end

  def previous_post
    @previous_post||= self.class.first(:conditions => ["published_on < ? AND site_name = ?", published_on, site_name], :order => "published_on desc")
  end

  def next_post
    @next_post||= self.class.first(:conditions => ["published_on > ? AND site_name = ?", published_on, site_name], :order => "published_on asc")
  end

end
