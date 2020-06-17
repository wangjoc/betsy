require "test_helper"

describe OrdersController do
  describe "show" do
    describe "show without login (guest)" do
      it "redirect if not logged in" do
        get order_path(Order.first.id)

        must_respond_with :redirect
        must_redirect_to root_path
      end
    end

    describe "show with login as merchant" do
      before do
        perform_login(merchants(:faker))
      end

      it "show order detail page if merchant has an orderitem on it" do
        get order_path(orders(:order_one).id)

        must_respond_with :success
      end

      it "do not show order detail page if merchant doesn't have orderitem on it" do
        get order_path(orders(:order_two).id)

        must_respond_with :redirect
        must_redirect_to dashboard_path
      end

      it "redirect to dashboard if order doesn't exist" do
        get order_path(-1)

        must_respond_with :redirect
        must_redirect_to dashboard_path
      end
    end
  end

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

  describe "create" do
    let (:customer_info) {
      {
        order: {
          buyer_name: "Huang Shaotian",
          email_address: "troublingrain@glory.com",
          mail_address: "City Blue Rain",
          zip_code: 33333,
          cc_one: 1111,
          cc_two: 1111,
          cc_three: 1111,
          cc_four: 1111,
          month: 12,
          year: 20,
          cc_cvv: 111,
        },
      }
    }

    it "creates a new order" do
      populate_cart

      expect {
        post orders_path, params: customer_info
      }.must_differ "Order.count", 1

      must_respond_with :redirect
      must_redirect_to confirm_path

      expect(Order.last.buyer_name).must_equal customer_info[:order][:buyer_name]
      expect(Order.last.email_address).must_equal customer_info[:order][:email_address]
      expect(Order.last.mail_address).must_equal customer_info[:order][:mail_address]
      expect(Order.last.zip_code).must_equal customer_info[:order][:zip_code].to_s
      expect(Order.last.cc_num).must_equal "************1111"
      expect(Order.last.cc_exp).must_equal "1220"
      expect(Order.last.cc_cvv).must_equal "***"

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
      populate_cart
      customer_info[:order][:cc_one] = ""

      expect {
        post orders_path, params: customer_info
      }.must_differ "Order.count", 0

      must_respond_with :bad_request
    end

    it "cannot create a new order if invalid date" do
      populate_cart
      customer_info[:order][:month] = "234"

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

  describe "purchase" do
    describe "purchase without login (guest)" do
      let (:customer_info) {
        {
          order: {
            buyer_name: "Huang Shaotian",
            email_address: "troublingrain@glory.com",
            mail_address: "City Blue Rain",
            zip_code: 33333,
            cc_one: 1111,
            cc_two: 1111,
            cc_three: 1111,
            cc_four: 1111,
            month: 12,
            year: 20,
            cc_cvv: 111,
          },
        }
      }

      before do
        populate_cart
        post orders_path, params: customer_info
      end

      it "changes status of pending order to paid" do
        expect(Order.last.status).must_equal "pending"
        expect(Order.last.order_items[0].product.stock).must_equal products(:lion).stock

        patch purchase_path(Order.last.id)

        expect(Order.last.status).must_equal "paid"
        expect(Order.last.order_items[0].product.stock).must_equal products(:lion).stock - Order.last.order_items[0].quantity
        must_respond_with :redirect
        must_redirect_to receipt_path
      end

      it "cannot change status of complete order to paid" do
        order = Order.last
        order.status = "complete"
        order.save

        expect(Order.last.status).must_equal "complete"
        patch purchase_path(Order.last.id)

        expect(Order.last.status).must_equal "complete"
        must_respond_with :redirect
        must_redirect_to order_path(order.id)
      end

      it "cannot change status of cancelled order to paid" do
        order = Order.last
        order.status = "cancelled"
        order.save

        expect(Order.last.status).must_equal "cancelled"
        patch purchase_path(Order.last.id)

        expect(Order.last.status).must_equal "cancelled"
        must_respond_with :redirect
        must_redirect_to order_path(order.id)
      end
    end
  end

  describe "purchase with login as merchant" do
    let (:customer_info) {
      {
        order: {
          buyer_name: "Huang Shaotian",
          email_address: "troublingrain@glory.com",
          mail_address: "City Blue Rain",
          zip_code: 33333,
          cc_one: 1111,
          cc_two: 1111,
          cc_three: 1111,
          cc_four: 1111,
          month: 12,
          year: 20,
          cc_cvv: 111,
        },
      }
    }

    before do
      perform_login
      populate_cart
      post orders_path, params: customer_info
    end

    it "changes status of pending order to paid" do
      expect(Order.last.status).must_equal "pending"
      patch purchase_path(Order.last.id)

      expect(Order.last.status).must_equal "paid"
      must_respond_with :redirect
      must_redirect_to receipt_path
    end

    it "cannot change status of complete order to paid" do
      order = Order.last
      order.status = "complete"
      order.save

      expect(Order.last.status).must_equal "complete"
      patch purchase_path(Order.last.id)

      expect(Order.last.status).must_equal "complete"
      must_respond_with :redirect
      must_redirect_to order_path(order.id)
    end

    it "cannot change status of cancelled order to paid" do
      order = Order.last
      order.status = "cancelled"
      order.save

      expect(Order.last.status).must_equal "cancelled"
      patch purchase_path(Order.last.id)

      expect(Order.last.status).must_equal "cancelled"
      must_respond_with :redirect
      must_redirect_to order_path(order.id)
    end
  end

  describe "cancel" do
    let (:customer_info) {
      {
        order: {
          buyer_name: "Huang Shaotian",
          email_address: "troublingrain@glory.com",
          mail_address: "City Blue Rain",
          zip_code: 33333,
          cc_one: 1111,
          cc_two: 1111,
          cc_three: 1111,
          cc_four: 1111,
          month: 12,
          year: 20,
          cc_cvv: 111,
        },
      }
    }

    before do
      populate_cart
      post orders_path, params: customer_info
      patch purchase_path(Order.last.id)
      get receipt_path
    end

    describe "cancel without login (guest)" do
      it "changes status of pending order to paid" do
        expect(Order.last.status).must_equal "paid"
        patch cancel_path(Order.last.id)

        expect(Order.last.status).must_equal "cancel"
        must_respond_with :redirect
        must_redirect_to products_path
      end

      it "changes status of complete order to cancelled" do
        order = Order.last
        order.status = "complete"
        order.save

        expect(Order.last.status).must_equal "complete"
        patch cancel_path(Order.last.id)

        expect(Order.last.status).must_equal "cancel"
        must_respond_with :redirect
        must_redirect_to products_path
      end

      it "changes status of paid order to cancelled" do
        order = Order.last
        order.status = "paid"
        order.save

        expect(Order.last.status).must_equal "paid"
        patch cancel_path(Order.last.id)

        expect(Order.last.status).must_equal "cancel"
        must_respond_with :redirect
        must_redirect_to products_path
      end
    end

    describe "cancel with login as merchant" do
      before do
        perform_login
        get dashboard_path
      end

      it "changes status of pending order to paid" do
        expect(Order.last.status).must_equal "paid"
        patch cancel_path(Order.last.id)

        expect(Order.last.status).must_equal "cancel"
        must_respond_with :redirect
        must_redirect_to dashboard_path
      end

      it "changes status of complete order to cancelled" do
        order = Order.last
        order.status = "complete"
        order.save

        expect(Order.last.status).must_equal "complete"
        patch cancel_path(Order.last.id)

        expect(Order.last.status).must_equal "cancel"
        must_respond_with :redirect
        must_redirect_to dashboard_path
      end

      it "changes status of paid order to cancelled" do
        order = Order.last
        order.status = "paid"
        order.save

        expect(Order.last.status).must_equal "paid"
        patch cancel_path(Order.last.id)

        expect(Order.last.status).must_equal "cancel"
        must_respond_with :redirect
        must_redirect_to dashboard_path
      end
    end
  end

  describe "receipt" do
    let (:customer_info) {
      {
        order: {
          buyer_name: "Huang Shaotian",
          email_address: "troublingrain@glory.com",
          mail_address: "City Blue Rain",
          zip_code: 33333,
          cc_one: 1111,
          cc_two: 1111,
          cc_three: 1111,
          cc_four: 1111,
          month: 12,
          year: 20,
          cc_cvv: 111,
        },
      }
    }

    before do
      populate_cart
      post orders_path, params: customer_info
    end

    describe "show without login (guest)" do
      it "show receipt if order is paid for and in session" do
        patch purchase_path(Order.last.id)
        expect(session[:order_id]).must_equal Order.last.id
        get receipt_path

        must_respond_with :success
        expect(session[:order_id]).must_be_nil
      end

      it "do not show receipt if order was cancelled" do
        # also covers scenario where session order_id is nil
        patch purchase_path(Order.last.id)
        patch cancel_path(Order.last.id)
        get receipt_path

        must_respond_with :redirect
        must_redirect_to products_path
      end

      it "do not show receipt if order is still pending" do
        get receipt_path

        must_respond_with :redirect
        must_redirect_to products_path
      end
    end

    describe "show without login (guest)" do
      before do
        perform_login
      end

      it "show receipt if order is paid for and in session" do
        patch purchase_path(Order.last.id)
        expect(session[:order_id]).must_equal Order.last.id
        get receipt_path

        must_respond_with :success
        expect(session[:order_id]).must_be_nil
      end

      it "do not show receipt if order was cancelled" do
        # also covers scenario where session order_id is nil
        patch purchase_path(Order.last.id)
        patch cancel_path(Order.last.id)
        get receipt_path

        must_respond_with :redirect
        must_redirect_to products_path
      end

      it "do not show receipt if order is still pending" do
        get receipt_path

        must_respond_with :redirect
        must_redirect_to products_path
      end
    end
  end

  describe "confirm" do
    describe "show confirm without login (guest)" do
      let (:customer_info) {
        {
          order: {
            buyer_name: "Huang Shaotian",
            email_address: "troublingrain@glory.com",
            mail_address: "City Blue Rain",
            zip_code: 33333,
            cc_one: 1111,
            cc_two: 1111,
            cc_three: 1111,
            cc_four: 1111,
            month: 12,
            year: 20,
            cc_cvv: 111,
          },
        }
      }

      before do
        get products_path
      end

      it "redirect if show confirm is not accessed directly from order confirm" do
        get confirm_path

        must_respond_with :redirect
        must_redirect_to products_path
      end

      it "redirect if order is not pending" do
        populate_cart
        post orders_path, params: customer_info
        patch purchase_path(Order.last.id)
        get confirm_path

        must_respond_with :redirect
        must_redirect_to products_path
      end

      it "show confirm if accessed directly from order confirm" do
        populate_cart
        post orders_path, params: customer_info
        get confirm_path

        must_respond_with :success
      end
    end

    describe "show confirm with login as merchant" do
      before do
        perform_login
        get products_path
      end

      let (:customer_info) {
        {
          order: {
            buyer_name: "Huang Shaotian",
            email_address: "troublingrain@glory.com",
            mail_address: "City Blue Rain",
            zip_code: 33333,
            cc_one: 1111,
            cc_two: 1111,
            cc_three: 1111,
            cc_four: 1111,
            month: 12,
            year: 20,
            cc_cvv: 111,
          },
        }
      }

      it "redirect if show confirm is not accessed directly from order confirm" do
        get confirm_path

        must_respond_with :redirect
        must_redirect_to products_path
      end

      it "redirect if order is not pending" do
        populate_cart
        post orders_path, params: customer_info
        patch purchase_path
        get confirm_path

        must_respond_with :redirect
        must_redirect_to products_path
      end

      it "show confirm if accessed directly from order confirm" do
        populate_cart
        post orders_path, params: customer_info
        get confirm_path

        must_respond_with :success
      end
    end
  end

  describe "ship" do
    describe "ship without login (guest)" do
      it "redirect if not logged in" do
        patch ship_path(orders(:order_one).id)

        must_respond_with :redirect
        must_redirect_to root_path
      end
    end

    describe "ship with login as merchant" do
      before do
        perform_login(merchants(:faker))
        @order_one = orders(:order_one)
        @order_two = orders(:order_two)
        @order_item_one = order_items(:item_one)
        @order_item_two = order_items(:item_two)
        get dashboard_path
      end

      it "ship orderitem that merchant owns if not already shipped" do
        patch ship_path(@order_one.id)

        must_respond_with :redirect
        must_redirect_to dashboard_path
        expect(@order_one.order_items.find_by(id: @order_item_one).is_shipped).must_equal true
        expect(@order_one.order_items.find_by(id: @order_item_two).is_shipped).must_equal false
      end

      it "do nothing if that merchant doesn't own anything" do
        patch ship_path(@order_two.id)

        must_respond_with :redirect
        must_redirect_to dashboard_path
        expect(@order_two.order_items[0].is_shipped).must_equal false
      end

      it "returns to order detail page if coming from order detail" do
        get order_path(@order_one.id)
        patch ship_path(@order_one.id)

        must_respond_with :redirect
        must_redirect_to order_path(@order_one.id)

        expect(@order_one.order_items.find_by(id: @order_item_one).is_shipped).must_equal true
        expect(@order_one.order_items.find_by(id: @order_item_two).is_shipped).must_equal false
      end
    end
  end
end
