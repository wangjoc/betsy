require "test_helper"

describe OrdersController do
  describe "show" do
    describe "show without login (guest)" do
      let (:customer_info) {
        {
          order: {
            buyer_name: "Ye Xiu",
            email_address: "lordgrim@glory.com",
            mail_address: "Happy Internet Cafe",
            zip_code: 11111,
            cc_num: 1111,
            cc_exp: 111111,
          },
        }
      }

      it "redirect if show page is not accessed directly from order confirm" do
        get order_path(Order.first.id)

        must_respond_with :redirect
      end

      it "redirect if accessing show page of other order" do
        populate_cart
        post orders_path, params: customer_info
        get order_path(Order.first.id)

        must_respond_with :redirect
      end

      it "show page if accessed directly from order confirm" do
        populate_cart
        post orders_path, params: customer_info
        get order_path(Order.last.id)

        must_respond_with :success
      end
    end

    describe "show with login as merchant" do
      before do 
        perform_login
      end
let (:customer_info) {
        {
          order: {
            buyer_name: "Ye Xiu",
            email_address: "lordgrim@glory.com",
            mail_address: "Happy Internet Cafe",
            zip_code: 11111,
            cc_num: 1111,
            cc_exp: 111111,
          },
        }
      }
      
      it "redirect if show page is not accessed directly from order confirm" do
        get order_path(Order.first.id)

        must_respond_with :redirect
      end

      it "redirect if accessing show page of other order" do
        populate_cart
        post orders_path, params: customer_info
        get order_path(Order.first.id)

        must_respond_with :redirect
      end

      it "show page if accessed directly from order confirm" do
        populate_cart
        post orders_path, params: customer_info
        get order_path(Order.last.id)

        must_respond_with :success
      end
    end
  end


  # describe "new" do
  #   describe "new without login (guest)" do
  #     it "responds with redirect if there nothing in cart" do
  #       get new_order_path

  #       must_respond_with :redirect
  #     end

  #     it "responds with success if there are orders in cart" do
  #       populate_cart
  #       get new_order_path
  
  #       must_respond_with :success
  #     end
  #   end

  #   describe "new with login as merchant" do
  #     before do 
  #       perform_login
  #     end

  #     it "responds with redirect if there nothing in cart, if logged in" do
  #       get new_order_path

  #       must_respond_with :redirect
  #     end

  #     it "responds with success if there are orders in cart, if logged in" do
  #       populate_cart
  #       get new_order_path

  #       must_respond_with :success
  #     end
  #   end
  # end

  # describe "create" do

  # end

  # describe "shopping cart" do
  #   # make sure to delete key/value pair if quantity < 0 
  #   # confirm that adding items works
  #   # confirm that subtracting items works
  #   # confirm that subtotal is correct
  # end
end
