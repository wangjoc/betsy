class MerchantsController < ApplicationController
  before_action :find_merchant, only: [:show]

  def index
    @merchants = Merchant.all 
  end

  def show  
  end

  def create
    auth_hash = request.env["omniauth.auth"]
    merchant = Merchant.find_by(uid: auth_hash[:uid], provider: "github")
    binding.pry
    if merchant
      flash[:success] = "Logged in as returning user #{merchant.name}"
    else
      merchant = Merchant.build_from_github(auth_hash)

      if merchant.save
        flash[:success] = "Logged in as new user #{merchant.name}"
      else
        flash[:error] = "Could not create new user account: #{merchant.errors.messages}"
        return redirect_to root_path
      end
    end
    
    # If we get here, we have a valid user instance
    session[:merchant_id] = merchant.id
    return redirect_to root_path
  end

  def logout
    session[:merchant_id] = nil
    flash[:success] = "Successfully logged out"
    redirect_to root_path
    return
  end

  def current
    unless @merchant
      flash[:error] = "You must be logged in to see this page"
      redirect_to root_path
      return
    end
  end

  private

  def find_merchant
    @merchant = Merchant.find_by(id: session[:merchant_id])
  end

end

