require "test_helper"

describe OrdersController do
  describe "new" do
    describe "new without login (guest)" do
      it "responds with redirect if there nothing in cart" do
        get new_order_path

        must_respond_with :redirect
      end

      it "responds with success if there are orders in cart" do
        populate_cart
        get new_order_path
  
        must_respond_with :success
      end
    end

    describe "new with login as merchant" do
      before do 
        perform_login
      end

      it "responds with redirect if there nothing in cart, if logged in" do
        get new_order_path

        must_respond_with :redirect
      end

      it "responds with success if there are orders in cart, if logged in" do
        populate_cart
        get new_order_path

        must_respond_with :success
      end
    end
  end
end
