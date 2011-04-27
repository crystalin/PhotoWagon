class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.authenticate(params[:login], params[:password])
    if user
      session[:user_id] = user.id
      redirect_to root_url, :notice => "Connexion r&#233;ussie".html_safe
    else
      flash.now.alert = "Le login ou le mot de passe est incorrect"
      render "new"
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url, :notice => "D&#233;connexion r&#233;ussie".html_safe
  end
end
