module ApplicationHelper

  def current_name
    current_admin_user.email[/[^\.]+/].capitalize if current_admin_user
  end

  def current_email
    current_admin_user.email if current_admin_user
  end
end
