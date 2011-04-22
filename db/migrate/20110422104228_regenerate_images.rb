class RegenerateImages < ActiveRecord::Migration
  def self.up
    Post.all.each do |post|
     post.image.recreate_versions!
    end
  end

  def self.down
    Post.all.each do |post|
     post.image.recreate_versions!
    end
  end
end
