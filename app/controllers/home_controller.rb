class HomeController < ApplicationController
  def install_picasa
    #also used to reset the cookies
    cookies.permanent[:last_post_date] = nil
  end
end
