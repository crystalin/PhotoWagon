class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_user
  helper_method :missing_photos
  helper_method :last_visited_page


  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => "L'acc&#233;s a cette page est r&#233;serv&#233;e aux administrateurs".html_safe
  end

  rescue_from ActiveRecord::RecordNotFound do |exception|
    redirect_to root_url, :alert => "La ressource (photo, commentaire,...) que vous cherchez est introuvable"
  end

  private

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def missing_photos
    @missing||= Post.where("published_on > ?", cookies[:last_post_date].to_time).count if cookies[:last_post_date]
    @missing||= 0
  end

  def last_visited_page
    @last_visited ||= (Post.where("published_on <= ?", cookies[:last_post_date].to_time).count / 15.0).to_f.floor + 1 if cookies[:page_counter].to_i > 1
  end

end
