require "test_helper"

describe Merchant do
  # it "does a thing" do
  #   value(1+1).must_equal 2
  # end

  before do
    @liya = merchants(:liya)
    @marta = merchants(:marta)
  end

  it "should be valid" do
    Merchant.all.each do |merchant|
      expect(merchant.valid?).must_equal true
    end
  end

  # I am going to fix/re-write this
  describe "merchant model relationship" do
    it "has a relationship to products" do
    expect(@liya.products.first.name).must_equal "something"
    expect(@liya.id).must_equal @liya.products.first.merchant_id
    expect(@marta.products.first.name).must_equal "something esle"
    expect(@marta.id).must_equal @marta.products.first.merchant_id
    end

    it "has many products" do
      something = products(:something)

      @liya.must_respond_to :products
      
      @liya.products.each do |product|
        product.must_be_kind of Product
      end
    end
  end





# end
