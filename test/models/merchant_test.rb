require "test_helper"

describe Merchant do
  let (:new_product) {
    Product.new(
      name: "Thousand Chance Umbrella",
      description: "Ultimate weapon (silver grade). Makes the unspecialized class feasible.",
      price: 1000,
      photo_url: "https://imgur.com/wC1RZzd",
      stock: 5
    )
  }

  let (:new_merchant) {
    Merchant.new(
      provider: "github",
      uid: "11111111",
      name: "Bao Rong Xing",
      email: "steamedbuninvasion@glory.com",
      avatar: "https://imgur.com/Q6snmV7.jpg"
    )
  }

  before do
    @merchant_faker = merchants(:faker)
    @merchant_greentye = merchants(:greentye)
  end

  # describe "instantiation" do
  #   it "can be instantiated" do
  #     expect(new_merchant.valid?).must_equal true
  #     expect(@merchant_faker.valid?).must_equal true
  #     expect(@merchant_greentye.valid?).must_equal true
  #   end

  #   it "will have the required fields" do
  #     new_merchant.save
  #     merchant = Merchant.last
  #     [:provider, :uid, :name, :email, :avatar].each do |field|
  #       expect(new_merchant).must_respond_to field
  #       expect(@merchant_faker).must_respond_to field
  #     end
  #   end
  # end

  # # https://stackoverflow.com/questions/34981661/creating-two-objects-in-one-controller-and-attaching-them-to-each-other-in-rails
  # describe "relationships" do
  #   before do 
  #     new_merchant.save
  #     @merchant = Merchant.last
  #   end

  #   it "can have no products" do
  #     expect(@merchant.products).must_be_empty
  #   end

  #   it "can have products" do
  #     expect(@merchant.products.length).must_equal 0

  #     new_product.merchant = @merchant
  #     new_product.save

  #     expect(Merchant.last.products.length).must_equal 1
  #     Merchant.last.products.each do |product|
  #       expect(product).must_be_instance_of Product
  #     end
  #   end
  # end

  # describe "validations" do
  #   it "must have a provider" do
  #     new_merchant.provider = nil

  #     expect(new_merchant.valid?).must_equal false
  #     expect(new_merchant.errors.messages).must_include :provider
  #     expect(new_merchant.errors.messages[:provider]).must_equal ["can't be blank"]
  #   end

  #   it "must have a uid" do
  #     new_merchant.uid = nil

  #     expect(new_merchant.valid?).must_equal false
  #     expect(new_merchant.errors.messages).must_include :uid
  #     expect(new_merchant.errors.messages[:uid]).must_equal ["can't be blank"]
  #   end

  #   it "must have a uid" do
  #     new_merchant.uid = nil

  #     expect(new_merchant.valid?).must_equal false
  #     expect(new_merchant.errors.messages).must_include :uid
  #     expect(new_merchant.errors.messages[:uid]).must_equal ["can't be blank"]
  #   end

  #   it 'must have unique uid' do
  #     new_merchant.uid = Merchant.last.uid
  #     result = new_merchant.save

  #     expect(result).must_equal false
  #   end

  #   it "must have a merchant name" do
  #     new_merchant.name = nil

  #     expect(new_merchant.valid?).must_equal false
  #     expect(new_merchant.errors.messages).must_include :name
  #     expect(new_merchant.errors.messages[:name]).must_equal ["can't be blank"]
  #   end

  #   it "must have a email address" do
  #     new_merchant.email = nil

  #     expect(new_merchant.valid?).must_equal false
  #     expect(new_merchant.errors.messages).must_include :email
  #     expect(new_merchant.errors.messages[:email]).must_equal ["can't be blank","is invalid"]
  #   end

  #   it 'must have unique email' do
  #     new_merchant.email = Merchant.last.email
  #     result = new_merchant.save

  #     expect(result).must_equal false
  #   end

  #   it "must have a valid email address" do
  #     new_merchant.email = "troublingrain"

  #     expect(new_merchant.valid?).must_equal false
  #     expect(new_merchant.errors.messages).must_include :email
  #     expect(new_merchant.errors.messages[:email]).must_equal ["is invalid"]
  #   end

  #   it "must have a avatar" do
  #     new_merchant.avatar = nil

  #     expect(new_merchant.valid?).must_equal false
  #     expect(new_merchant.errors.messages).must_include :avatar
  #     expect(new_merchant.errors.messages[:avatar]).must_equal ["can't be blank"]
  #   end
  # end

  describe "custom tests" do
    describe "get_merchant_order_items?" do
      it "get all of a merchant's order items" do
        order_item_count = 0
        Merchant.all.each do |merchant|
          Merchant.get_merchant_order_items(merchant.id).each do |x|
            order_item_count += 1
            expect(x).must_be_instance_of OrderItem
            expect(x.product.merchant).must_equal merchant
          end
        end

        expect(OrderItem.all.length).must_equal order_item_count
      end
    end

    
  end
end
