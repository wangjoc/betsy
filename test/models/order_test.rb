require "test_helper"

describe Order do
  let (:order_item) {
    OrderItem.new(
      quantity: 10,
      product: products(:diaper),
      is_shipped: false
    )
  }

  let (:new_order) {
    Order.new(
      buyer_name: "Huang Shaotian",
      email_address: "troublingrain@glory.com",
      mail_address: "City Blue Rain",
      zip_code: "33333",
      cc_num: "************1111",
      cc_exp: 1230,
      cc_cvv: "***",
      order_items: [order_item]
    )
  }

  before do 
    @order_one = orders(:order_one)
    @order_two = orders(:order_two)
    @merchant_faker = merchants(:faker)
    @merchant_greentye = merchants(:greentye)
    @merchant_dancingrain = merchants(:dancingrain)
  end

  describe "instantiation" do
    it "can be instantiated" do
      expect(new_order.valid?).must_equal true
      expect(@order_one.valid?).must_equal true
      expect(@order_two.valid?).must_equal true
    end

    it "will have the required fields" do
      new_order.save
      order = Order.last
      [:buyer_name, :email_address, :mail_address, :zip_code, :cc_exp, :cc_exp, :status].each do |field|
        expect(order).must_respond_to field
        expect(@order_one).must_respond_to field
      end
    end
  end

  # https://stackoverflow.com/questions/34981661/creating-two-objects-in-one-controller-and-attaching-them-to-each-other-in-rails
  describe "relationships" do
    it "can have many order items" do
      expect(@order_one.order_items.count).must_equal 2
      @order_one.order_items.each do |order_item|
        expect(order_item).must_be_instance_of OrderItem
      end
    end

    it "must have at least one order item" do
      new_order.order_items = []
      new_order.save
      expect(new_order.save).must_equal false
    end
  end

  describe "validations" do
    it "must have a buyer name" do
      new_order.buyer_name = nil

      expect(new_order.valid?).must_equal false
      expect(new_order.errors.messages).must_include :buyer_name
      expect(new_order.errors.messages[:buyer_name]).must_equal ["can't be blank"]
    end

    it "must have a email address" do
      new_order.email_address = nil

      expect(new_order.valid?).must_equal false
      expect(new_order.errors.messages).must_include :email_address
      expect(new_order.errors.messages[:email_address]).must_equal ["can't be blank", "is invalid"]
    end

    it "must have a valid email address" do
      new_order.email_address = "troublingrain"

      expect(new_order.valid?).must_equal false
      expect(new_order.errors.messages).must_include :email_address
      expect(new_order.errors.messages[:email_address]).must_equal ["is invalid"]
    end

    it "must have a mail address" do
      new_order.mail_address = nil

      expect(new_order.valid?).must_equal false
      expect(new_order.errors.messages).must_include :mail_address
      expect(new_order.errors.messages[:mail_address]).must_equal ["can't be blank"]
    end

    it "must have a zip code" do
      new_order.zip_code = nil

      expect(new_order.valid?).must_equal false
      expect(new_order.errors.messages).must_include :zip_code
      expect(new_order.errors.messages[:zip_code]).must_equal ["can't be blank", "is not a number", "is the wrong length (should be 5 characters)"]
    end

    it "must have a numerical zip code" do
      new_order.zip_code = "string"

      expect(new_order.valid?).must_equal false
      expect(new_order.errors.messages).must_include :zip_code
      expect(new_order.errors.messages[:zip_code]).must_equal ["is not a number", "is the wrong length (should be 5 characters)"]
    end

    it "must have a valid zip code (not greater than 5)" do
      new_order.zip_code = 1234567890

      expect(new_order.valid?).must_equal false
      expect(new_order.errors.messages).must_include :zip_code
      expect(new_order.errors.messages[:zip_code]).must_equal ["is the wrong length (should be 5 characters)"]
    end

    it "must have a valid zip code (not less than 5)" do
      new_order.zip_code = 123

      expect(new_order.valid?).must_equal false
      expect(new_order.errors.messages).must_include :zip_code
      expect(new_order.errors.messages[:zip_code]).must_equal ["is the wrong length (should be 5 characters)"]
    end

    it "must have a credit card number" do
      new_order.cc_num = nil

      expect(new_order.valid?).must_equal false
      expect(new_order.errors.messages).must_include :cc_num
      expect(new_order.errors.messages[:cc_num]).must_equal ["can't be blank", "is the wrong length (should be 16 characters)", "is invalid"]
    end

    it "must hide all but last four digits" do
      new_order.cc_num = "1234123412341234"

      expect(new_order.valid?).must_equal false
      expect(new_order.errors.messages).must_include :cc_num
      expect(new_order.errors.messages[:cc_num]).must_equal ["is invalid"]
    end

    it "must hide all four digits using *" do
      new_order.cc_num = "XXXXXXXXXXXX1234"

      expect(new_order.valid?).must_equal false
      expect(new_order.errors.messages).must_include :cc_num
      expect(new_order.errors.messages[:cc_num]).must_equal ["is invalid"]
    end

    it "last four digits must be numbers" do
      new_order.cc_num = "************rand"

      expect(new_order.valid?).must_equal false
      expect(new_order.errors.messages).must_include :cc_num
      expect(new_order.errors.messages[:cc_num]).must_equal ["is invalid"]
    end

    it "must be long enough (can't be less than 16)" do
      new_order.cc_num = "****1234"

      expect(new_order.valid?).must_equal false
      expect(new_order.errors.messages).must_include :cc_num
      expect(new_order.errors.messages[:cc_num]).must_equal ["is the wrong length (should be 16 characters)", "is invalid"]
    end

    it "must be long enough (can't be more than 16)" do
      new_order.cc_num = "********************1234"

      expect(new_order.valid?).must_equal false
      expect(new_order.errors.messages).must_include :cc_num
      expect(new_order.errors.messages[:cc_num]).must_equal ["is the wrong length (should be 16 characters)"]
    end

    it "must have credit card exp" do
      new_order.cc_exp = nil

      expect(new_order.valid?).must_equal false
      expect(new_order.errors.messages).must_include :cc_exp
      expect(new_order.errors.messages[:cc_exp]).must_equal ["can't be blank", "is the wrong length (should be 4 characters)", "is invalid"]
    end

    it "credit card exp single month digit works" do
      new_order.cc_exp = '0101'
      expect(new_order.valid?).must_equal true
    end

    it "must have credit card cvv" do
      new_order.cc_cvv = nil

      expect(new_order.valid?).must_equal false
      expect(new_order.errors.messages).must_include :cc_cvv
      expect(new_order.errors.messages[:cc_cvv]).must_equal ["can't be blank", "is the wrong length (should be 3 characters)", "is invalid"]
    end

    it "cvv input is incorrect" do
      new_order.cc_cvv = '*******'

      expect(new_order.valid?).must_equal false
      expect(new_order.errors.messages).must_include :cc_cvv
      expect(new_order.errors.messages[:cc_cvv]).must_equal ["is the wrong length (should be 3 characters)"]
    end

    it "cvv input is incorrect" do
      new_order.cc_cvv = 'dfgh'

      expect(new_order.valid?).must_equal false
      expect(new_order.errors.messages).must_include :cc_cvv
      expect(new_order.errors.messages[:cc_cvv]).must_equal ["is the wrong length (should be 3 characters)", "is invalid"]
    end

    it "must have order items" do
      new_order.order_items = []
      
      expect(new_order.valid?).must_equal false
      expect(new_order.errors.messages).must_include :order_items
      expect(new_order.errors.messages[:order_items]).must_equal ["can't be blank"]
    end
  end

  describe "custom tests" do
    describe "contains_merchant?" do
      it "contains merchant if order has their product" do
        expect(Order.contains_merchant?(@order_one.id, @merchant_faker.id)).must_equal true
        expect(Order.contains_merchant?(@order_one.id, @merchant_greentye.id)).must_equal true
      end

      it "doesn't contain merchant order doesn't have their product" do
        expect(Order.contains_merchant?(@order_one.id, @merchant_dancingrain.id)).must_equal false  
        expect(Order.contains_merchant?(@order_two.id, @merchant_dancingrain.id)).must_equal false 
        expect(Order.contains_merchant?(@order_two.id, @merchant_faker.id)).must_equal false
      end
    end
  end
end
