require "test_helper"
require 'pry'

describe ProductsController do
  before do 
    merch_params = {
      name: "Harry Potter",
      uid: "123456",
      provider: "github",
      email: "harrypotter@hogwarts.com"
    }

    Merchant.create(merch_params)

    @prod_params = {
      name: "Used Diapers", 
      description: "Best-selling product! Especially known for it's special fragrance.",
      price: 99.99,
      photo_url: "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcQ2WjvkDEuH0p5E24TITgJkjV-szXPIvxXT1La-nd7PcbFPxsre&usqp=CAU",
      stock: 10,
      merchant_id: 1
     }
  end

  describe "index" do
    it "responds with success when there are products saved" do
      # Ensure that there is at least two Products saved
      Product.create(@prod_params)

      get "/products"
      must_respond_with :success   
    end

    it "responds with success when there are no products saved" do
      get "/products"
      must_respond_with :success
    end
  end

  describe "show" do
    it "responds with success when showing an existing valid product" do
      # Ensure that there is a product saved
      @product = Product.create(@product_params)
      valid_product_id = @product.id
      get "/products/#{valid_product_id}"
      must_respond_with :success
    end

    it "responds with redirection 302 with an invalid product id" do
      @product = Product.create(@product_params)
      invalid_product_id = 999
      get "/products/#{invalid_product_id}"
      must_respond_with :redirect
    end
  end

  describe "new" do
    it "responds with success" do
      get new_product_path

      must_respond_with :success
    end
  end

  # describe "create" do
  #   describe "Logged in users" do
  #     before do
  #       perform_login
  #     end

  #     let (:product_hash) {
  #       {
  #         product: {
  #           name: "Soiled Diapers", 
  #           description: "Best-selling product! Especially known for it's special fragrance.",
  #           price: 99.99,
  #           photo_url: "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcQ2WjvkDEuH0p5E24TITgJkjV-szXPIvxXT1La-nd7PcbFPxsre&usqp=CAU",
  #           stock: 10
  #         }
  #       }
  #     }

  #     it "can create a new product with valid information accurately, and redirect" do
  #       perform_login
  #       expect {
  #         post products_path, params: product_hash[:product]
  #       }.must_differ 'Product.count', 1

  #       must_respond_with :redirect
  #       must_redirect_to product_path(Product.last.id)
        
  #       expect(Product.last.name).must_equal product_params[:product][:name]
  #       expect(Product.last.description).must_equal product_params[:product][:description]
  #     end

  #     it "does not create a driver if the form data violates Driver validations, and responds with a redirect" do
  #       driver_hash[:driver][:name] = nil

  #       expect {
  #         post drivers_path, params: driver_hash
  #       }.must_differ "Driver.count", 0

  #       must_respond_with :bad_request
  #     end
  #   end
  # end

  # TODO - Hala, JW put in tests for the custom paths for products since they are related to the shopping cart. Please feel free to add more as needed

  describe "add_to_cart" do
    before do
      # Go to products_path to get a return_to session key
      get products_path
      @product_lion = products(:lion)
      @product_diaper = products(:diaper)
      @product_toliet = products(:toliet)
      @product_zero_stock = products(:zero_stock)
    end

    describe "add_to_cart without login (guest)" do
      it "add product to cart if enough stock" do
        patch add_to_cart_path(@product_lion.id)
        expect(session[:shopping_cart][@product_lion.id.to_s]).must_equal 1

        get products_path
        patch add_to_cart_path(@product_diaper.id)
        expect(session[:shopping_cart][@product_diaper.id.to_s]).must_equal 1

        must_respond_with :redirect
        must_redirect_to products_path

        # TODO - cart_num_items should increase by 1 is add is successful in application test
      end

      it "do not add product to cart if not enough stock" do
        patch add_to_cart_path(@product_toliet.id)
        expect(session[:shopping_cart][@product_toliet.id.to_s]).must_equal 1
        get products_path

        patch add_to_cart_path(@product_toliet.id)
        expect(session[:shopping_cart][@product_toliet.id.to_s]).must_equal 1

        must_respond_with :redirect
        must_redirect_to products_path
      end

      it "do not add product to cart if stock is zero" do
        patch add_to_cart_path(@product_zero_stock.id)
        expect(session[:shopping_cart][@product_zero_stock.id.to_s]).must_equal nil

        must_respond_with :redirect
        must_redirect_to products_path
      end

      it "redirect back to product show if added from there" do
        get product_path(@product_lion.id)
        patch add_to_cart_path(@product_lion.id)
        expect(session[:shopping_cart][@product_lion.id.to_s]).must_equal 1

        must_respond_with :redirect
        must_redirect_to product_path(@product_lion.id)
      end

      it "redirect back to order show if added from there" do
        patch add_to_cart_path(@product_lion.id)
        expect(session[:shopping_cart][@product_lion.id.to_s]).must_equal 1

        get new_order_path
        patch add_to_cart_path(@product_lion.id)
        expect(session[:shopping_cart][@product_lion.id.to_s]).must_equal 2

        must_respond_with :redirect
        must_redirect_to new_order_path
      end

      it "responds with redirection 302 with an invalid product id" do
        invalid_product_id = 999
        get "/products/#{invalid_product_id}"
        must_respond_with :redirect
      end
    end

    describe "add_to_cart login as master" do
      # TODO - consider adding logic to prevent merchant from buying own product? (similar to how they can't review own product)
      before do
        perform_login
      end

      it "add product to cart if enough stock" do
        patch add_to_cart_path(@product_lion.id)
        expect(session[:shopping_cart][@product_lion.id.to_s]).must_equal 1

        get products_path
        patch add_to_cart_path(@product_diaper.id)
        expect(session[:shopping_cart][@product_diaper.id.to_s]).must_equal 1

        must_respond_with :redirect
        must_redirect_to products_path

        # TODO - cart_num_items should increase by 1 is add is successful in application test
      end

      it "do not add product to cart if not enough stock" do
        patch add_to_cart_path(@product_toliet.id)
        expect(session[:shopping_cart][@product_toliet.id.to_s]).must_equal 1
        get products_path

        patch add_to_cart_path(@product_toliet.id)
        expect(session[:shopping_cart][@product_toliet.id.to_s]).must_equal 1

        must_respond_with :redirect
        must_redirect_to products_path
      end

      it "do not add product to cart if stock is zero" do
        patch add_to_cart_path(@product_zero_stock.id)
        expect(session[:shopping_cart][@product_zero_stock.id.to_s]).must_equal nil

        must_respond_with :redirect
        must_redirect_to products_path
      end

      it "redirect back to product show if added from there" do
        get product_path(@product_lion.id)
        patch add_to_cart_path(@product_lion.id)
        expect(session[:shopping_cart][@product_lion.id.to_s]).must_equal 1

        must_respond_with :redirect
        must_redirect_to product_path(@product_lion.id)
      end

      it "redirect back to order show if added from there" do
        patch add_to_cart_path(@product_lion.id)
        expect(session[:shopping_cart][@product_lion.id.to_s]).must_equal 1

        get new_order_path
        patch add_to_cart_path(@product_lion.id)
        expect(session[:shopping_cart][@product_lion.id.to_s]).must_equal 2

        must_respond_with :redirect
        must_redirect_to new_order_path
      end

      it "responds with redirection 302 with an invalid product id" do
        invalid_product_id = 999
        get "/products/#{invalid_product_id}"
        must_respond_with :redirect
      end
    end  
  end

  describe "remove_from_cart" do
    before do
      # Go to products_path to get a return_to session key
      get products_path
      @product_lion = products(:lion)
      @product_diaper = products(:diaper)
      @product_toliet = products(:toliet)

      patch add_to_cart_path(@product_lion.id)
      get products_path
      patch add_to_cart_path(@product_lion.id)
      get products_path
      patch add_to_cart_path(@product_toliet.id)
      get new_order_path
    end

    describe "remove_from_cart without login (guest)" do
      it "remove product from cart, if in cart" do
        expect(session[:shopping_cart][@product_lion.id.to_s]).must_equal 2
        patch remove_from_cart_path(@product_lion.id)
        expect(session[:shopping_cart][@product_lion.id.to_s]).must_equal 1

        must_respond_with :redirect
        must_redirect_to new_order_path
      end

      it "remove key/value from cart, if reduced to 0" do
        patch remove_from_cart_path(@product_toliet.id)
        expect(session[:shopping_cart][@product_toliet.id.to_s]).must_equal nil

        must_respond_with :redirect
        must_redirect_to new_order_path
      end

      it "no change to shopping cart if item not in cart" do
        expect(session[:shopping_cart][@product_diaper.id.to_s]).must_equal nil
        patch remove_from_cart_path(@product_diaper.id)
        expect(session[:shopping_cart][@product_diaper.id.to_s]).must_equal nil

        must_respond_with :redirect
        must_redirect_to new_order_path
      end

      it "responds with redirection 302 with an invalid product id" do
        invalid_product_id = 999
        get "/products/#{invalid_product_id}"
        must_respond_with :redirect
      end
    end

    describe "remove_from_cart login as master" do
      before do 
        perform_login
      end

      it "remove product from cart, if in cart" do
        expect(session[:shopping_cart][@product_lion.id.to_s]).must_equal 2
        patch remove_from_cart_path(@product_lion.id)
        expect(session[:shopping_cart][@product_lion.id.to_s]).must_equal 1

        must_respond_with :redirect
        must_redirect_to new_order_path
      end

      it "remove key/value from cart, if reduced to 0" do
        patch remove_from_cart_path(@product_toliet.id)
        expect(session[:shopping_cart][@product_toliet.id.to_s]).must_equal nil

        must_respond_with :redirect
        must_redirect_to new_order_path
      end

      it "no change to shopping cart if item not in cart" do
        expect(session[:shopping_cart][@product_diaper.id.to_s]).must_equal nil
        patch remove_from_cart_path(@product_diaper.id)
        expect(session[:shopping_cart][@product_diaper.id.to_s]).must_equal nil

        must_respond_with :redirect
        must_redirect_to new_order_path
      end

      it "responds with redirection 302 with an invalid product id" do
        invalid_product_id = 999
        get "/products/#{invalid_product_id}"
        must_respond_with :redirect
      end
    end
  end

  describe "delete_from_cart" do
    before do
      # Go to products_path to get a return_to session key
      get products_path
      @product_lion = products(:lion)
      @product_diaper = products(:diaper)
      @product_toliet = products(:toliet)

      patch add_to_cart_path(@product_lion.id)
      get products_path
      patch add_to_cart_path(@product_lion.id)
      get products_path
      patch add_to_cart_path(@product_toliet.id)
      get new_order_path
    end

    describe "remove_from_cart without login (guest)" do
      it "remove all type of product from cart, if in cart" do
        expect(session[:shopping_cart][@product_lion.id.to_s]).must_equal 2
        patch delete_from_cart_path(@product_lion.id)
        expect(session[:shopping_cart][@product_lion.id.to_s]).must_equal nil

        must_respond_with :redirect
        must_redirect_to new_order_path
      end

      it "no change to shopping cart if item not in cart" do
        expect(session[:shopping_cart][@product_diaper.id.to_s]).must_equal nil
        patch remove_from_cart_path(@product_diaper.id)
        expect(session[:shopping_cart][@product_diaper.id.to_s]).must_equal nil

        must_respond_with :redirect
        must_redirect_to new_order_path
      end

      it "responds with redirection 302 with an invalid product id" do
        invalid_product_id = 999
        get "/products/#{invalid_product_id}"
        must_respond_with :redirect
      end
    end

    describe "remove_from_cart login as merchant" do
      before do 
        perform_login
      end
      it "remove all type of product from cart, if in cart" do
        expect(session[:shopping_cart][@product_lion.id.to_s]).must_equal 2
        patch delete_from_cart_path(@product_lion.id)
        expect(session[:shopping_cart][@product_lion.id.to_s]).must_equal nil

        must_respond_with :redirect
        must_redirect_to new_order_path
      end

      it "no change to shopping cart if item not in cart" do
        expect(session[:shopping_cart][@product_diaper.id.to_s]).must_equal nil
        patch remove_from_cart_path(@product_diaper.id)
        expect(session[:shopping_cart][@product_diaper.id.to_s]).must_equal nil

        must_respond_with :redirect
        must_redirect_to new_order_path
      end

      it "responds with redirection 302 with an invalid product id" do
        invalid_product_id = 999
        get "/products/#{invalid_product_id}"
        must_respond_with :redirect
      end
    end
  end
end
