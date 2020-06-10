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

end
