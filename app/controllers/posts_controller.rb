class PostsController < ApplicationController
  def index
    @posts = Post.order('published_on desc').page(params[:page]).per(9)
  end

  def show
    @post = Post.find(params[:id])
  end

  def new
    @post = Post.new
  end

  def create
    @post = Post.new(params[:post])
    params[:notice] = 'Post was successfully created.' if @post.save
    redirect_to @post
  end

  def edit
    @post = Post.find(params[:id])
  end

  def update
    @post = Post.find(params[:id])
    params[:notice] = 'Post was successfully updated.' if @post.update_attributes(params[:post])
    redirect_to @post
  end

  def destroy
    if @post.destroy!
      params[:notice] = 'Memorial was successfully deleted.'
      @post.remove_image!
    end
    redirect_to posts_path
  end

  def recreate_images
    Post.all.each do |post|
     post.image.recreate_versions!
    end
    redirect_to posts_path
  end

  def picasa
    if not params['rss']
      @items = [{
            "title" => "P1120383.JPG","description" => "Bon... pas directement mais en tout cas, le repas me donne envie d'y aller. Je peux vous assurer que c'est delicieux !!","thumbnail" => "http://localhost:3113/58498d8c858e8448e551fd8fe418487f/thumb/e2f1ad12a9c7187f.jpg","imgsrc"=>"http://localhost:3113/58498d8c858e8448e551fd8fe418487f/image/e2f1ad12a9c7187f.jpg",
            "group"=>{
              "content"=>[
                {"url"=>"http://localhost:3113/58498d8c858e8448e551fd8fe418487f/image/e2f1ad12a9c7187f.jpg","width"=>"3712","height"=>"2088","isDefault"=>"true"},
                {"url"=>"http://localhost:3113/58498d8c858e8448e551fd8fe418487f/original/e2f1ad12a9c7187f","width"=>"3712","height"=>"2088","fileSize"=>"2864593","type"=>"image/jpeg"}
              ],
              "thumbnail"=>{"url"=>:"http://localhost:3113/58498d8c858e8448e551fd8fe418487f/thumb/e2f1ad12a9c7187f.jpg","width"=>"144","height"=>"81"}
            }
          },
          {"title"=>"P1120383.JPG", "description"=>"Bon... pas directement mais en tout cas, le repas me donne envie d'y aller. Je peux vous assurer que c'est delicieux !!", "thumbnail"=>"http://localhost:3113/58498d8c858e8448e551fd8fe418487f/thumb/e2f1ad12a9c7187f.jpg", "imgsrc"=>"http://localhost:3113/58498d8c858e8448e551fd8fe418487f/image/e2f1ad12a9c7187f.jpg", "group"=>{"content"=>[{"url"=>"http://localhost:3113/58498d8c858e8448e551fd8fe418487f/image/e2f1ad12a9c7187f.jpg", "width"=>"3712", "height"=>"2088", "isDefault"=>"true"}, {"url"=>"http://localhost:3113/58498d8c858e8448e551fd8fe418487f/original/e2f1ad12a9c7187f", "width"=>"3712", "height"=>"2088", "fileSize"=>"2864593", "type"=>"image/jpeg"}], "thumbnail"=>{"url"=>"http://localhost:3113/58498d8c858e8448e551fd8fe418487f/thumb/e2f1ad12a9c7187f.jpg", "width"=>"144", "height"=>"81"}}}]
      params[:notice] = 'No Rss Provided'
    else
      rss_hash = Hash.from_xml(params['rss'].tempfile)
      @items = rss_hash['rss']['channel']['item']
      if not @items.is_a? Array
        @items = [@items]
      end
#      puts rss_hash.to_json
#      puts @items
    end
    render :layout => false
  end

  def picasa_upload
#    puts params.to_yaml
    params[:notice] ||= ""
    params.each do |name, uploaded_file|
      if uploaded_file.is_a? ActionDispatch::Http::UploadedFile
        post = Post.new(:image => uploaded_file)
        if post.save
          params[:notice] += "#{uploaded_file.original_filename} uploaded.\n "
        else
          params[:notice] += "#{uploaded_file.original_filename} FAILED.\n "
        end
      end
    end
    render :nothing => true
  end


end
