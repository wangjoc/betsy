require "test_helper"

describe OrdersController do
  describe "new" do
    it "responds with redirect if there nothing in cart" do
      get new_order_path

      must_respond_with :redirect
    end

    it "responds with success if there are orders in cart" do
      populate_cart
      get new_order_path

      must_respond_with :success
    end

    it "responds with redirect if there nothing in cart, if logged in" do
      perform_login
      get new_order_path

      must_respond_with :redirect
    end

    it "responds with success if there are orders in cart, if logged in" do
      perform_login
      populate_cart
      get new_order_path

      must_respond_with :success
    end
  end
end
