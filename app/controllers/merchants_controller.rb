class MerchantsController < ApplicationController
  def index
    @merchants = Merchant.all 
  end

  def show
    @merchants = Merchant.find_by ... something
  end

  def create
    #probably do auth here
  end

  def destroy
    # session? 
  end








end
