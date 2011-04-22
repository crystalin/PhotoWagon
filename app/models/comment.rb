class Comment < ActiveRecord::Base
  attr_accessible :author, :content

  belongs_to :post

  validates_presence_of :post_id

  scope :recent, order("created_at DESC")
end
