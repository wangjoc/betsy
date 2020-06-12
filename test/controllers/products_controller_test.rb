require "test_helper"
require "pry"

describe ProductsController do
  before do
    merch_params = {
      name: "Harry Potter",
      uid: "123456",
      provider: "github",
      email: "harrypotter@hogwarts.com",
    }

    Merchant.create(merch_params)

    @prod_params = {
      name: "Used Diapers",
      description: "Best-selling product! Especially known for it's special fragrance.",
      price: 99.99,
      photo_url: "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcQ2WjvkDEuH0p5E24TITgJkjV-szXPIvxXT1La-nd7PcbFPxsre&usqp=CAU",
      stock: 10,
      merchant_id: 1,
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
  #       binding.pry
  #       expect {
  #         post products_path, params: product_hash[:product]
  #       }.must_differ 'Product.count', 1

  #       binding.pry

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

end
