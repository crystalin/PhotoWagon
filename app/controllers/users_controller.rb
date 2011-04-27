class UsersController < ApplicationController

  load_and_authorize_resource :except => [:install]

  def new
  end

  def create
    if @user.save
      redirect_to root_url, :notice => "Signed up!"
    else
      render "new"
    end
  end

  def edit
  end

  def update
    params[:notice] = 'User was successfully updated.' if @user.update_attributes(params[:user])
    redirect_to root_url
  end

  def install
    if User.count == 0
      @user= User.new(:name => "Alan", :email => "admin", :password => "admin", :password_confirmation => "admin")
      @user.role = "admin"
      @user.save!
      session[:user_id] = @user.id
      redirect_to edit_user_path(@user), :notice => "admin/admin has been created"
    else
      redirect_to root_path, :alert => "Installation is not possible anymore"
    end
  end
end
