require "test_helper"

describe ReviewsController do
  describe "create" do
    it "responds with not found if product is nil" do
      product_id = "taco"
      review_info = {
        review: {
          rating: 5,
          review_text: "Tacos are a really good food",
          product_id: product_id,
        },
      }

      expect {
        post product_reviews_path(product_id), params: review_info
      }.wont_differ "Review.count"

      must_respond_with :redirect
    end

    it "creates a new review if product is valid" do
      product = products(:lion)
      review_info = {
        review: {
          rating: 5,
          review_text: "Tacos are a really good food",
          product_id: product.id,
        },
      }

      expect {
        post product_reviews_path(product.id), params: review_info
      }.must_change "Review.count", 1

      must_respond_with :redirect
      must_redirect_to product_path(product.id)
    end

    it 'allows logged in merchant to review products they do not sell' do
      merchant = merchants(:faker)
      product = products(:lion)
      perform_login(merchant)

      review_info = {
        review: {
          rating: 1,
          review_text: "Bad looking lions - horrible",
          product_id: product.id,
        },
      }

      expect {
        post product_reviews_path(product.id), params: review_info
      }.must_change "Review.count", 1
    end

    it "does not allow merchant to review own products if merchant is logged in" do
      # get a merchant
      merchant = merchants(:faker)

      # log in that merchant
      perform_login(merchant)

      # create a product that belongs to that merchant
      product = Product.create(
        merchant_id: merchant.id,
        name: "Prop product",
        description: "Use me on stage!",
        price: 3.99,
        photo_url: "https://imgur.com/paTfP93.jpg",
        stock: 3,
      )

      # create a review for that merchant's product while that merchant is logged in - you can check that using session
      review_info = {
        review: {
          rating: 5,
          review_text: "This is the best thing I have ever sold",
          product_id: product.id,
        },
      }

      expect {
        post product_reviews_path(product.id), params: review_info
      }.wont_change "Review.count"

      expect(flash[:warning]).must_equal 'Boooo!!! We at regrEtsy pride ourselves in our unbiased reviews. You ought to be ashamed of trying to review your own product! >:('
    end
  end
end
