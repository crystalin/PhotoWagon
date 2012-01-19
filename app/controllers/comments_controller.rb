class CommentsController < ApplicationController
  load_and_authorize_resource
  skip_load_resource :only => :create

  rescue_from ActiveRecord::RecordInvalid do |exception|
    flash[:alert] = "Nom ou contenu du commentaire incomplet (minimum 2 caracteres)"
    redirect_to @post
  end

  def index
    @comments = Comment.on_site(current_subdomain).recent.includes(:post => :comments).page(params[:page]).per(30)
  end

  def new
    redirect_to root_url, :notice => "Pour ecrire un commentaire, merci d'aller sur la page de la photo d'abord"
  end

  def create
    flash[:alert]= "Posting is disabled".html_safe
    redirect_to @post
    #@post = Post.find(params[:post_id])
    #@comment = @post.comments.build(params[:comment])
    #cookies.permanent[:comment_name] = @comment.author if @comment.author
    #if @comment.save!
    #  redirect_to @post, :notice => "Votre commentaire a &#233;t&#233; publi&#233;".html_safe
    #else
    #  flash[:alert]= "Impossible de cr&#233;er le commentaire".html_safe
    #  redirect_to @post
    #end
  end

  def edit

  end

  def update
    if @comment.update_attributes(params[:comment])
      redirect_to root_url, :notice  => "Successfully updated comment."
    else
      flash[:notice]= "Error while editing the comment."
      render @post
    end
  end

  def destroy
    if @comment.delete
      redirect_to root_url, :notice  => "Successfully deleted comment."
    else
      flash[:notice]= "Error while deleting the comment."
      render @comment
    end
  end
end
