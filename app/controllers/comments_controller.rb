class CommentsController < ApplicationController
  def new
    redirect_to root_url, :notice => "Pour ecrire un commentaire, merci d'aller sur la page de la photo d'abord"
  end

  def create
    @post = Post.find(params[:post_id])
    @comment = @post.comments.build(params[:comment])
    if @comment.save
      redirect_to @post, :notice => "Successfully created comment."
    else
      flash[:notice]= "Error while creating the comment."
      render @post
    end
  end

  def update
    @comment = Comment.find(params[:id])
    if @comment.update_attributes(params[:comment])
      redirect_to root_url, :notice  => "Successfully updated comment."
    else
      flash[:notice]= "Error while editing the comment."
      render @post
    end
  end
end
