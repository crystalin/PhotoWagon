class AddGoodCoverToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :good_cover, :boolean
  end
end
