class AddCropFrontToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :crop_front_x, :integer

    add_column :posts, :crop_front_y, :integer

    add_column :posts, :crop_front_w, :integer

    add_column :posts, :crop_front_h, :integer

  end
end
