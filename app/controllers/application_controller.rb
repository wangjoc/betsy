class ApplicationController < ActionController::Base
  # before_action :require_login
  before_action :navigation_data

  def navigation_data
    @categories = Category.all
    @merchants = Merchant.all
  end

  def current_merchant
    # return user matching id from session variable
    return Merchant.find_by(id: session[:merchant_id]) if session[:merchant_id]
  end

  def require_login
    if current_merchant.nil?
      flash[:warning] = "Please #{ view_context.link_to "login", github_login_path } to perform this action"
      redirect_to root_path
    end
  end
end
