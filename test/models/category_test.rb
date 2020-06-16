require "test_helper"

describe Category do
  let (:new_category) {
    Category.new(
      category: "Weapons",
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

  describe "relationships" do
    before do
      new_category.save
      @category = Category.last
      @product_diaper = products(:diaper)
      @product_toilet = products(:toilet)
    end

    it "can have no products" do
      expect(@category.products).must_be_empty
    end

    it "can have products" do
      expect(@category.products.length).must_equal 0

      @category.products << @product_diaper
      @category.save

      expect(Category.last.products.length).must_equal 1
      Category.last.products.each do |product|
        expect(product).must_be_instance_of Product
      end

      @category.products << @product_toilet
      @category.save

      expect(Category.last.products.length).must_equal 2
    end
  end

  describe "validations" do
    it "must have a category" do
      new_category.category = nil

      expect(new_category.valid?).must_equal false
      expect(new_category.errors.messages).must_include :category
      expect(new_category.errors.messages[:category]).must_equal ["can't be blank"]
    end

    it "must have unique category" do
      new_category.category = Category.last.category
      result = new_category.save

      expect(result).must_equal false
    end
  end
end
