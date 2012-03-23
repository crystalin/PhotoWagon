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
      post.crop_cover_x
    end
    div :class => 'picasa_post_front' do
      form_for post, :as => :post, :method => :get, :url => {:action => :crop_cover} do |f|
        inputs = ""
        #for attribute in [:crop_cover_x, :crop_cover_y, :crop_cover_h, :crop_cover_w]
        #  inputs << f.hidden_field(attribute, :id => attribute)
        #end
        inputs << f.hidden_field(:crop_cover_x, :value => post.crop_cover_x || 0, :class => 'cover_x')
        inputs << f.hidden_field(:crop_cover_y, :value => post.crop_cover_y || 0, :class => 'cover_y')
        inputs << f.hidden_field(:crop_cover_w, :value => post.crop_cover_w || post.information["ImageWidth"], :class => 'cover_w')
        inputs << f.hidden_field(:crop_cover_h, :value => post.crop_cover_h || post.information["ImageWidth"] / ImageUploader::IMAGE_SIZES[:front_page][0] * ImageUploader::IMAGE_SIZES[:front_page][1], :class => 'cover_h')
        inputs << f.submit("Crop")
        inputs.html_safe
      end
    end
    div :class => 'crop_preview' do
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
    post.crop_cover_x = params[:post]["crop_cover_x"].to_i
    post.crop_cover_y = params[:post]["crop_cover_y"].to_i
    post.crop_cover_h = params[:post]["crop_cover_h"].to_i
    post.crop_cover_w = params[:post]["crop_cover_w"].to_i
    post.image.recreate_versions!
    post.save!
    redirect_to :action => :show, :notice => "Image cropped"
  end

  collection_action :picasa_upload do
    if params['rss'].nil?
      params[:notice] = 'No Rss Provided'
      #redirect_to root_path
      @items = []
      Post.limit(1).order('id desc').each do |post|
        @items <<  { "imgsrc" => post.image_url}
      end
    end
  end

  collection_action :picasa_create, :method => :post do

    @posts = []
    redirect_to :action => :picasa_upload, :notice => "Missing the photos" if not params['postset'] or not params['postset']['post']
    #puts params['postset']['post']
    params['postset']['post'].each do |index, post_data|
      #puts "post "
      #puts post
      if (post_data['keep_it'] == "true")
        post = Post.new(post_data)
        post.remote_image_url = "http://localhost:3000/#{post_data['image']}"
        post.site_name = 'zurich'
        post.save!
      end
    end
    render @posts.to_xml
  end

  action_item :only => :show do
    link_to "Update IPTC data", read_information_admin_post_path(post), :confirm => "Description and Title will be replaced.\n\nAre you sure?"
  end

  action_item do
    link_to "Picasa Upload", picasa_upload_admin_posts_path
  end



  end
