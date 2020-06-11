require "test_helper"

describe OrdersController do
  describe "new" do
    it "responds with success if there nothing in cart" do
      get new_order_path

      must_respond_with :redirect
    end

    it "responds with success if there are orders in cart" do
      populate_cart
      get new_order_path

      must_respond_with :success
    end
  end
end
