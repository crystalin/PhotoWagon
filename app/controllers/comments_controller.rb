class CommentsController < ApplicationController
  load_and_authorize_resource
  skip_load_resource :only => :create

  def index
    @comments = Comment.recent.includes(:post => :comments).page(params[:page]).per(15)
  end

  def new
    redirect_to root_url, :notice => "Pour ecrire un commentaire, merci d'aller sur la page de la photo d'abord"
  end

  def create
    @post = Post.find(params[:post_id])
    @comment = @post.comments.build(params[:comment])
    if @comment.save!
      redirect_to @post, :notice => "Votre commentaire a &#233;t&#233; publi&#233;".html_safe
    else
      flash[:alert]= "Impossible de cr&#233;er le commentaire".html_safe
      redirect_to @post
    end
  end

  def update
    if @comment.update_attributes(params[:comment])
      redirect_to root_url, :notice  => "Successfully updated comment."
    else
      flash[:notice]= "Error while editing the comment."
      render @post
    end
  end
end
