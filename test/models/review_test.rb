require "test_helper"

describe Review do
  let (:new_review) {
    Review.new(
      rating: 3,
      review_text: "A sample review",
      product: products(:diaper),
    )
  }

  describe "instantiation" do
    it "can be instantiated" do
      expect(new_review.valid?).must_equal true
    end

    it "has required fields" do
      [:rating, :review_text, :product].each do |field|
        expect(new_review).must_respond_to field
      end
    end
  end

  describe "relationships" do
    it "can access products" do
      new_review.save

      expect(new_review.product).must_be_instance_of Product
      expect(new_review.product.name).must_equal "Used Diaper"
    end
  end

  describe "validations" do
    it "is not valid without a rating" do
      new_review.rating = nil
      new_review.save

      expect(new_review.valid?).must_equal false
      expect(new_review.errors.messages).must_include :rating
      expect(new_review.errors.messages[:rating]).must_equal ["can't be blank", "is not a number"]
    end
  end
end
