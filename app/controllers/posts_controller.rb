class PostsController < ApplicationController
  before_filter :find_post, :only => :show

  def index
    @posts = Post.on_site(current_subdomain).recent.includes(:comments).page(params[:page]).per(15)
#    if cookies[:page_counter] > 1
#      @last_post = @posts.all.first
#      update_cookie @last_post if @last_post
#    end
  end

  def beginning
    @posts = Post.on_site(current_subdomain).story.includes(:comments).page(params[:page]).per(15)
    @last_post = @posts.all.last
    update_cookie @last_post if @last_post
    render "index"
  end

#  def recent
#    if cookies[:last_post_date]
#      @posts = Post.order('published_on asc').where("published_on > ?", cookies[:last_post_date]).includes(:comments).page(params[:page]).per(15)
#      update_cookie @posts.last if @posts.last
#      if @posts.empty?
#        redirect_to posts_path, :notice => "Vous avez d&#233;j&#224; vu toutes les nouvelles photos".html_safe
#      else
#        render "index"
#      end
#    else
#      redirect_to beginning_posts_path, :notice => "Commen&#231;ons par le d&#233;but de l'histoire".html_safe
#    end
#  end

  def show
    @comment = Comment.new
    @comment.post = @post
  end

  def new
  end

  def create
    @post.update_attribute :site_name, current_subdomain
    params[:notice] = 'Post was successfully created.' if @post.save
    redirect_to @post
  end

  def edit
  end

  def update
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

  private
  def find_post
    @post = Post.includes(:comments).find(params[:id])
  end

  def update_cookie(last_post)
    if cookies["last_post_date_#{current_subdomain}"].nil? || cookies["last_post_date_#{current_subdomain}"].empty? || (cookies["last_post_date_#{current_subdomain}"].to_time < last_post.published_on)
      cookies.permanent["last_post_date_#{current_subdomain}"] = last_post.published_on
    end

  end

end
