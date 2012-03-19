ActiveAdmin.register Post do

  #index :as => :grid do |post|
  #  link_to(image_tag(post.image_url(:front_page)), admin_post_path(post))
  #end

  index :as => :block do |post|
    div :class => 'post_image', :for => post do
      link_to(image_tag(post.image_url(:front_page)), admin_post_path(post))
    end
  end

  show do
    h3 post.title
    div do
      post.body
    end
    div do
      form_for post, :as => :post, :method => :get, :url => {:action => :crop_cover} do |f|
        inputs = ""
        for attribute in [:crop_cover_x, :crop_cover_y, :crop_cover_h, :crop_cover_w]
          inputs << f.hidden_field(attribute, :id => attribute)
        end
        inputs << hidden_field_tag(:body)
        inputs << f.submit("Crop")
        inputs.html_safe
      end
    end
    div :class => 'preview' do
      image_tag(post.image_url)
    end
    div do
      image_tag(post.image_url(:cover))
    end
    div do
      image_tag(post.image_url, :id => 'cropbox')
    end
  end

  member_action :read_information do
    post = Post.find(params[:id])
    post.read_information
    post.save!
    redirect_to :action => :show, :notice => "Information read and save"
  end

  member_action :crop_cover do
    post = Post.find(params[:id])
    post.crop_cover_x = params[:post]["crop_cover_x"]
    post.crop_cover_y = params[:post]["crop_cover_y"]
    post.crop_cover_h = params[:post]["crop_cover_h"]
    post.crop_cover_w = params[:post]["crop_cover_w"]
    post.image.recreate_versions!
    post.save!
    redirect_to :action => :show, :notice => "Image cropped"
  end

  action_item :only => :show do
    link_to "Update IPTC data", read_information_admin_post_path(post), :confirm => "Description and Title will be replaced.\n\nAre you sure?"
  end


end
