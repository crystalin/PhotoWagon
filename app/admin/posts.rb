ActiveAdmin.register Post do
  skip_before_filter :verify_authenticity_token, :only => :picasa_upload
  before_filter :authenticate_active_admin_user , :except => :picasa_upload

  require 'zip/zip'

  #index :as => :grid do |post|
  #  link_to(image_tag(post.image_url(:cover_page)), admin_post_path(post))
  #end

  index :as => :block do |post|
    div :class => 'post_image', :for => post do
      link_to(image_tag(post.image_url(:front_page)), admin_post_path(post))
    end
  end

  show do
    h3 post.title
    div do
      form_for(post, :as => :post, :method => :post, :url => {:action => :crop}) do |f|
        output = f.submit("Crop")
        output << content_tag('div', :class => 'picasa_post_front') do
          output2 = content_tag('div', :class => 'image') do
            output3 = f.hidden_field(:crop_front_x, :value => post.crop_front_x || -1, :class => 'crop_x')
            output3 << f.hidden_field(:crop_front_y, :value => post.crop_front_y || -1, :class => 'crop_y')
            output3 << f.hidden_field(:crop_front_w, :value => post.crop_front_w || -1, :class => 'crop_w')
            output3 << f.hidden_field(:crop_front_h, :value => post.crop_front_h || -1, :class => 'crop_h')
            output3 <<  image_tag(post.image_url, :class => 'cropbox')
            output3
          end
          output2 << content_tag('canvas', nil, :width => 300, :height => 168, :class => 'crop_canvas')
          output2
        end
        output << content_tag('div', :class => 'picasa_post_cover') do
          output2 = content_tag('div', :class => 'image') do
            output3 = f.hidden_field(:crop_cover_x, :value => post.crop_cover_x || -1, :class => 'crop_x')
            output3 << f.hidden_field(:crop_cover_y, :value => post.crop_cover_y || -1, :class => 'crop_y')
            output3 << f.hidden_field(:crop_cover_w, :value => post.crop_cover_w || -1, :class => 'crop_w')
            output3 << f.hidden_field(:crop_cover_h, :value => post.crop_cover_h || -1, :class => 'crop_h')
            output3 <<  image_tag(post.image_url, :class => 'cropbox')
            output3
          end
          output2 << content_tag('canvas', nil, :width => 972, :height => 240, :class => 'crop_canvas')
          output2
        end
        #div :class => 'picasa_post_cover' do
        #  div do
        #    div :class => 'image' do
        #      output = ""
        #      output << f.hidden_field(:crop_cover_x, :value => post.crop_cover_x || -1, :class => 'crop_x')
        #      output << f.hidden_field(:crop_cover_y, :value => post.crop_cover_y || -1, :class => 'crop_y')
        #      output << f.hidden_field(:crop_cover_w, :value => post.crop_cover_w || -1, :class => 'crop_w')
        #      output << f.hidden_field(:crop_cover_h, :value => post.crop_cover_h || -1, :class => 'crop_h')
        #      output << image_tag(post.image_url, :class => 'cropbox')
        #      output.html_safe
        #    end
        #    div do
        #      content_tag('canvas', nil, :width => 972, :height => 240, :class => 'crop_canvas')
        #    end
        #  end
        #end
      end
    end
  end

  member_action :read_information do
    post = Post.find(params[:id])
    post.read_information
    post.save!
    redirect_to :action => :show, :notice => "Information read and save"
  end

  member_action :crop, :method => :post do
    post = Post.find(params[:id])
    post.crop_front_x = params[:post]["crop_front_x"].to_i
    post.crop_front_y = params[:post]["crop_front_y"].to_i
    post.crop_front_h = params[:post]["crop_front_h"].to_i
    post.crop_front_w = params[:post]["crop_front_w"].to_i
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
  end if Rails.env.development?

  collection_action :picasa_upload, :method => :post do
    @items = []
    if params['rss'].nil?
      if Rails.env.development?
        Post.limit(1).order('id desc').each do |post|
          @items <<  { "imgsrc" => post.image_url}
        end
      else
        params[:notice] = 'No Rss Provided'
        redirect_to root_path
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
        post.remote_image_url = "#{post_data['image']}" if Rails.env.development?
        post.site_name = current_subdomain
        post.save!
      end
    end
    render :nothing => true
  end

  action_item :only => :show do
    link_to "Update IPTC data", read_information_admin_post_path(post), :confirm => "Description and Title will be replaced.\n\nAre you sure?"
  end

  action_item :only => :index do
    link_to "Picasa Upload", picasa_upload_admin_posts_path
  end if Rails.env.development?

  action_item :only => :index do
    link_to "Picasa Install", picasa_install_admin_posts_path
  end



  end
