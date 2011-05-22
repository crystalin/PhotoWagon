class AddSiteNameToPosts < ActiveRecord::Migration
  def self.up
    add_column :posts, :site_name, :string
    Post.all.each do |post|
      post.update_attribute :site_name, "japon"
    end
  end

  def self.down
    remove_column :posts, :site_name
  end
end
