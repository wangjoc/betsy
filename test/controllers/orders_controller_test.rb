require "test_helper"

describe OrdersController do
#   describe "show" do
#     describe "show without login (guest)" do
#       let (:customer_info) {
#         {
#           order: {
#             buyer_name: "Ye Xiu",
#             email_address: "lordgrim@glory.com",
#             mail_address: "Happy Internet Cafe",
#             zip_code: 11111,
#             cc_num: 1111,
#             cc_exp: 111111,
#           },
#         }
#       }

#       it "redirect if show page is not accessed directly from order confirm" do
#         get order_path(Order.first.id)

#         must_respond_with :redirect
#       end

#       it "redirect if accessing show page of other order" do
#         populate_cart
#         post orders_path, params: customer_info
#         get order_path(Order.first.id)

#         must_respond_with :redirect
#       end

#       it "show page if accessed directly from order confirm" do
#         populate_cart
#         post orders_path, params: customer_info
#         get order_path(Order.last.id)

#         must_respond_with :success
#       end
#     end

#     describe "show with login as merchant" do
#       before do 
#         perform_login
#       end
# let (:customer_info) {
#         {
#           order: {
#             buyer_name: "Ye Xiu",
#             email_address: "lordgrim@glory.com",
#             mail_address: "Happy Internet Cafe",
#             zip_code: 11111,
#             cc_num: 1111,
#             cc_exp: 111111,
#           },
#         }
#       }
      
#       it "redirect if show page is not accessed directly from order confirm" do
#         get order_path(Order.first.id)

#         must_respond_with :redirect
#       end

#       it "redirect if accessing show page of other order" do
#         populate_cart
#         post orders_path, params: customer_info
#         get order_path(Order.first.id)

#         must_respond_with :redirect
#       end

#       it "show page if accessed directly from order confirm" do
#         populate_cart
#         post orders_path, params: customer_info
#         get order_path(Order.last.id)

#         must_respond_with :success
#       end
#     end
#   end

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

  describe "create" do
    # TODO - JW change zip code to be integer instead of string
    let (:customer_info) {
      {
        order: {
          buyer_name: "Ye Xiu",
          email_address: "lordgrim@glory.com",
          mail_address: "Happy Internet Cafe",
          zip_code: "11111",
          cc_num: 1111,
          cc_exp: 111111,
        },
      }
    }

    it "creates a new order" do
      populate_cart
        
      expect {
        post orders_path, params: customer_info
      }.must_differ 'Order.count', 1

      must_respond_with :redirect
      must_redirect_to order_path(Order.last.id)
      expect(Order.last.buyer_name).must_equal customer_info[:order][:buyer_name]
      expect(Order.last.email_address).must_equal customer_info[:order][:email_address]
      expect(Order.last.mail_address).must_equal customer_info[:order][:mail_address]
      expect(Order.last.zip_code).must_equal customer_info[:order][:zip_code]
      expect(Order.last.cc_num).must_equal customer_info[:order][:cc_num]
      expect(Order.last.cc_exp).must_equal customer_info[:order][:cc_exp]

      expect(Order.last.order_items[0]).must_equal OrderItem.last
    end

    it "cannot create a new order if missing customer name" do 
      populate_cart
      customer_info[:order][:buyer_name] = nil

      expect {
        post orders_path, params: customer_info
      }.must_differ "Order.count", 0

      must_respond_with :bad_request
    end

    it "cannot create a new order if missing email address" do 
      populate_cart
      customer_info[:order][:email_address] = nil

      expect {
        post orders_path, params: customer_info
      }.must_differ "Order.count", 0

      must_respond_with :bad_request
    end

    it "cannot create a new order if missing mail address" do 
      populate_cart
      customer_info[:order][:mail_address] = nil

      expect {
        post orders_path, params: customer_info
      }.must_differ "Order.count", 0

      must_respond_with :bad_request
    end

    it "cannot create a new order if zip code is invalid" do 
      populate_cart
      customer_info[:order][:zip_code] = 1111111

      expect {
        post orders_path, params: customer_info
      }.must_differ "Order.count", 0

      must_respond_with :bad_request
    end

    it "cannot create a new order if missing credit card is wrong length" do 
      #TODO change to limiting length later (will need to update seeds and yml as well)
      #TODO make sure only last four digits of CC are kept
      populate_cart
      customer_info[:order][:cc_num] = nil

      expect {
        post orders_path, params: customer_info
      }.must_differ "Order.count", 0

      must_respond_with :bad_request
    end

    it "cannot create a new order if past exp date" do 
      #TODO change to expired date later, still figuring out how to format the info
      populate_cart
      customer_info[:order][:cc_exp] = nil

      expect {
        post orders_path, params: customer_info
      }.must_differ "Order.count", 0

      must_respond_with :bad_request
    end

    it "cannot create order if there are no items in shopping cart" do
      expect {
        post orders_path, params: customer_info
      }.must_differ "Order.count", 0

      must_redirect_to products_path
    end
  end

  # describe "shopping cart" do
  #   # make sure to delete key/value pair if quantity < 0 
  #   # confirm that adding items works
  #   # confirm that subtracting items works
  #   # confirm that subtotal is correct
  # end
end
