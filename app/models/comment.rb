class Comment < ActiveRecord::Base
  attr_accessible :author, :content

  belongs_to :post

  validates_presence_of :post_id
  validates_presence_of :author
  validates_length_of :author, :minimum => 2
  validates_presence_of :content
  validates_length_of :content, :minimum => 2

  scope :recent, order("created_at DESC")
end
