class AddCropCoverToPost < ActiveRecord::Migration
  def change
    add_column :posts, :crop_cover_x, :integer

    add_column :posts, :crop_cover_y, :integer

    add_column :posts, :crop_cover_w, :integer

    add_column :posts, :crop_cover_h, :integer

  end
end
