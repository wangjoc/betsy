require "test_helper"

describe MerchantsController do
  # it "does a thing" do
  #   value(1+1).must_equal 2
  # end
  describe "index" do
    it "can get the index page" do
      get merchants_path

      must_respond_with :success
    end
  end

  describe "show" do
    it "can get the show page" do
      merchant = merchants(:hannah)
      get merchant_path(merchant)

      must_respond_with :success
    end
  end

  describe "dashboard" do 
    it "can get the dashboard page" do 
      merchant = merchants(:hannah)
      perform_login(merchant)
      get dashboard_path

      must_respond_with :success
    end

    it "can't get to the dashboard page if not logged in" do 
      get dashboard_path 

      must_respond_with :not_found
    end
  end

  describe "confirmation" do 
    it "can get to a confirmation page" do 
      merchant = merchants(:hannah)
      op = OrderProduct.first
      perform_login(merchant)
      
      get merchant_confirmation_path(op.order_id)
      must_respond_with :success
    end

  #   it "should not get into a confirmation page if not logged in" do 
      
  # end











  end 
end
