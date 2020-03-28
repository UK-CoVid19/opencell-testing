class HomeController < ApplicationController
  def index
    if current_user && current_user.patient?
      redirect_to user_path(current_user)
      return
    elsif current_user && current_user.staff?
      redirect_to staff_dashboard_path
      return
    else
      render 'index'
    end
  end

  def privacy

  end

  def about

  end
end
