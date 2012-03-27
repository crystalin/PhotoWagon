ActiveAdmin.register Post do
  skip_before_filter :verify_authenticity_token, :only => :picasa_upload
  before_filter :authenticate_active_admin_user , :except => :picasa_upload

  require 'zip/zip'

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

  collection_action :picasa_install do
    #also used to reset the cookies
    cookies.permanent["last_post_date_#{current_subdomain}"] = nil

    @filename = "#{request.host}_picasa_upload.pbz"
    @uuid = UUIDTools::UUID.md5_create(UUIDTools::UUID_DNS_NAMESPACE, request.host_with_port)

    template = ERB.new IO.read(Rails.root.join('app','views','picasa','button.xml.erb'))
    @pbf = template.result(binding)
    render 'picasa/install'
  end


  collection_action :picasa_upload, :method => :get do
  end

  collection_action :picasa_upload, :method => :post do
    @items = []
    if params['rss'].nil?
      params[:notice] = 'No Rss Provided'
      #redirect_to root_path
      Post.limit(1).order('id desc').each do |post|
        @items <<  { "imgsrc" => post.image_url}
      end
    else
      content = params['rss']["tempfile"] || params['rss']
      rss_hash = Hash.from_xml(content)
      @items = rss_hash['rss']['channel']['item']
      if not @items.is_a? Array
        @items = [@items]
      end
    end
  end

  collection_action :picasa_create, :method => :post do

    @posts = []
    redirect_to :action => :picasa_upload, :notice => "Missing the photos" if not params['postset'] or not params['postset']['post']
    params['postset']['post'].each do |index, post_data|
      if (post_data['keep_it'] == "true")
        post = Post.new(post_data)
        post.remote_image_url = "#{post_data['image']}"
        post.site_name = 'zurich'
        post.save!
      end
    end
    redirect_to :action => :index, :notice => 'Posts added'
  end

  action_item :only => :show do
    link_to "Update IPTC data", read_information_admin_post_path(post), :confirm => "Description and Title will be replaced.\n\nAre you sure?"
  end

  action_item do
    link_to "Picasa Upload", picasa_upload_admin_posts_path
  end

  action_item do
    link_to "Picasa Install", picasa_install_admin_posts_path
  end



  end
