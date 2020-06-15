require "test_helper"

describe Category do
  let (:new_category) {
    Category.new(
      category: "Weapons"
    )
  }

  before do
    @category_indoor = categories(:indoor)
    @category_outdoor = categories(:outdoor)
  end

  describe "instantiation" do
    it "can be instantiated" do
      expect(new_category.valid?).must_equal true
      expect(@category_indoor.valid?).must_equal true
      expect(@category_outdoor.valid?).must_equal true
    end

    it "will have the required fields" do
      new_category.save

      [:category].each do |field|
        expect(new_category).must_respond_to field
        expect(@category_indoor).must_respond_to field
      end
    end
  end
end
