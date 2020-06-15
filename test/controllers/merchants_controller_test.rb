require "test_helper"

describe MerchantsController do
  describe "show" do
    before do 
      @merchant_faker = merchants(:faker)
    end

    describe "show without login (guest)" do
      it "can get the show page for valid merchant" do
        get merchant_path(@merchant_faker.id)

        must_respond_with :success
      end

      it "redirect show if invalid merchant" do
        get merchant_path(-1)

        must_respond_with :redirect
        must_redirect_to products_path
      end
    end

    describe "show with login as merchant" do
      before do 
        perform_login
      end

      it "can get the show page for valid merchant" do
        get merchant_path(@merchant_faker.id)

        must_respond_with :success
      end

      it "redirect show if invalid merchant" do
        get merchant_path(-1)

        must_respond_with :redirect
        must_redirect_to products_path
      end
    end


  end

  # describe "dashboard" do 
  #   it "can get the dashboard page" do 
  #     merchant = merchants(:hannah)
  #     perform_login(merchant)
  #     get dashboard_path

  #     must_respond_with :success
  #   end

  #   it "can't get to the dashboard page if not logged in" do 
  #     get dashboard_path 

  #     must_respond_with :not_found
  #   end
  # end

  # describe "confirmation" do 
  #   it "can get to a confirmation page" do 
  #     merchant = merchants(:hannah)
  #     op = OrderProduct.first
  #     perform_login(merchant)
      
  #     get merchant_confirmation_path(op.order_id)
  #     must_respond_with :success
  #   end

  #   it "should not get into a confirmation page if not logged in" do 
      
  # end











end
