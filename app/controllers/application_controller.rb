class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :missing_photos
  helper_method :last_visited_page
  helper_method :comment_name
  helper_method :comment_email
  helper_method :current_subdomain

  before_filter :restore_cookies
  before_filter :subdomain_view_path

  #rescue_from ActiveRecord::RecordNotFound do |exception|
  #  redirect_to root_url, :alert => "La ressource (photo, commentaire,...) que vous cherchez est introuvable"
  #end

  private

  def missing_photos
    @missing||= Post.on_site(current_subdomain).where("published_on > ?", cookies["last_post_date_#{current_subdomain}"].to_time).count if cookies["last_post_date_#{current_subdomain}"]
    @missing||= 0
  end

  def last_visited_page
    @last_visited ||= (Post.on_site(current_subdomain).where("published_on <= ?", cookies["last_post_date_#{current_subdomain}"].to_time).count / 15.0).to_f.floor + 1
  end

  def comment_name
    @comment_name ||= cookies[:comment_name]
  end

  def comment_email
    comment_email ||= cookies[:comment_email]
  end

  def current_subdomain
    @subdomain ||= "zurich" if Rails.env.development?
    @subdomain ||= request.subdomain.presence || "zurich"
  end

  def restore_cookies
    if cookies["last_post_date"]
      cookies.permanent["last_post_date_#{current_subdomain}"] ||= cookies["last_post_date"]
      cookies.delete "last_post_date"
    end
  end

  def subdomain_view_path
    prepend_view_path "app/views/sites/#{current_subdomain}"

  end

end
