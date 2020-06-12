class MerchantsController < ApplicationController
  before_action :find_merchant, only: [:show, :dashboard]

  def index
    @products_by_merchant = Product.categorize_by_merchant
    session[:return_to] = merchants_path
  end

  def show  
    # diff than the merchant session for login
    @merchant = Merchant.find_by(id: params[:id])
    @products = Product.by_merchant(@merchant.id)
    session[:return_to] = merchant_path(@merchant.id)
  end

  def dashboard
    session[:return_to] = dashboard_path
  end

  def create
    auth_hash = request.env["omniauth.auth"]
    merchant = Merchant.find_by(uid: auth_hash[:uid], provider: "github")

    if merchant
      flash[:success] = :success
      flash[:message] = "Logged in as returning user #{merchant.name}"
    else
      merchant = Merchant.build_from_github(auth_hash)

      if merchant.save
        flash[:success] = :success
        flash[:message] = "Logged in as new user #{merchant.name}"
      else
        flash[:status] = :error
        flash[:message] = "Could not create new user account: #{merchant.errors.messages}"
        flash[:error] = merchant.errors
        return redirect_to root_path
      end
    end
    
    # If we get here, we have a valid user instance
    session[:merchant_id] = merchant.id
    return redirect_to root_path
  end

  def destroy
    session[:user_id] = nil
    flash[:status] = :success
    flash[:message] = "Successfully logged out"

    redirect_to merchant_path
  end

  def confirmation
    @merchant = @current_merchant
    @order = Order.find_by(id: params[:id])

    check_merchant
  end

  def logout
    session[:merchant_id] = nil
    flash[:success] = "Successfully logged out"
    redirect_to root_path
    return
  end

  # def current
  #   unless @merchant
  #     flash[:error] = "You must be logged in to see this page"
  #     redirect_to root_path
  #     return
  #   end
  # end

  private

  # def check_merchant
  #   unless @merchant
  #     render_404
  #   end
  # end

  def find_merchant
    @merchant = Merchant.find_by(id: session[:merchant_id])
  end

end

