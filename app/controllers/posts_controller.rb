class PostsController < ApplicationController

  def index
    @posts = Post.on_site(current_subdomain).recent.includes(:comments).page(params[:page]).per(15)
  end

  def beginning
    @posts = Post.on_site(current_subdomain).story.includes(:comments).page(params[:page]).per(15)
    @last_post = @posts.all.last
    update_cookie @last_post if @last_post
    render "index"
  end

  def show
    @post = Post.includes(:comments).find(params[:id])
    @comment = Comment.new
    @comment.post = @post
    @comment.post = @post
  end

  def new
  end

  def create
    @post = Post.new(params[:post])
    @post.update_attribute :site_name, current_subdomain
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
    @post = Post.find(params[:id])
    if @post.destroy!
      params[:notice] = 'Post was successfully deleted.'
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

  def update_cookie(last_post)
    if cookies["last_post_date_#{current_subdomain}"].nil? || cookies["last_post_date_#{current_subdomain}"].empty? || (cookies["last_post_date_#{current_subdomain}"].to_time < last_post.published_on)
      cookies.permanent["last_post_date_#{current_subdomain}"] = last_post.published_on
    end
  end

end
