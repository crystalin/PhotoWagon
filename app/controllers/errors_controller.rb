class ErrorsController < ApplicationController
  def routing
    redirect_to root_path, :alert => "La page que vous cherchez n'existe pas"
  end
end