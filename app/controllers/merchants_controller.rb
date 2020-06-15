class MerchantsController < ApplicationController
  before_action :find_merchant, only: [:show, :dashboard, :logout]
  before_action :require_login, only: [:dashboard]

  def show  
    @merchant = Merchant.find_by(id: params[:id])

    if @merchant.nil?
      flash[:warning] = "Merchant does not exist"
      redirect_to products_path
      return
    end

    @products = Product.by_merchant(@merchant.id)
    session[:return_to] = merchant_path(@merchant.id)
  end

  def dashboard
    @merchant_orders = Merchant.get_merchant_orders(@merchant.id)
    @merchant_order_items = Merchant.get_merchant_order_items(@merchant.id)
    session[:return_to] = dashboard_path
  end

  def create
    auth_hash = request.env["omniauth.auth"]
    merchant = Merchant.find_by(uid: auth_hash[:uid], provider: "github")

    if merchant
      flash[:success] = "Logged in as returning user #{merchant.name}"
    else
      merchant = Merchant.build_from_github(auth_hash)

      if merchant.save
        flash[:success] = "Logged in as new user #{merchant.name}"
      else
        flash[:warning] = "Could not create new user account: #{merchant.errors.messages}"
        flash[:warning] = merchant.errors
        return redirect_to root_path
      end
    end
    
    session[:merchant_id] = merchant.id
    return redirect_to root_path
  end

  # TODO - Hannah, what is this method doing? Do we really need it?
  def confirmation
    @merchant = @current_merchant
    @order = Order.find_by(id: params[:id])

    check_merchant
  end

  def logout
    flash[:success] = "Successfully logged out of #{@merchant.name}"
    session[:merchant_id] = nil
    redirect_to root_path
    return
  end

  private

  # TODO - Hannah, what is this method doing? Do we really need it?
  # def check_merchant
  #   unless @merchant
  #     render_404
  #   end
  # end

  def find_merchant
    @merchant = Merchant.find_by(id: session[:merchant_id])
  end

end

