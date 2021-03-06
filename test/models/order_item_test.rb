require "test_helper"

describe OrderItem do
  let (:new_order) {
    Order.new(
      buyer_name: "Huang Shaotian",
      email_address: "troublingrain@glory.com",
      mail_address: "City Blue Rain",
      zip_code: "33333",
      cc_num: "************1111",
      cc_exp: 1230,
      cc_cvv: "***",
    )
  }

  let (:order_item) {
    OrderItem.new(
      quantity: 10,
      product: products(:diaper),
      order: new_order,
      is_shipped: false,
    )
  }

  before do
    @item_one = order_items(:item_one)
    @item_two = order_items(:item_two)
    @order_one = orders(:order_one)
    @order_two = orders(:order_two)
    @merchant_faker = merchants(:faker)
    @product_lion = products(:lion)
    @product_toilet = products(:toilet)
  end

  describe "instantiation" do
    it "can be instantiated" do
      expect(order_item.valid?).must_equal true
      expect(@item_one.valid?).must_equal true
      expect(@item_two.valid?).must_equal true
    end

    it "will have the required fields" do
      order_item.save
      new_order_item = OrderItem.last
      [:quantity, :product_id, :order_id, :is_shipped].each do |field|
        expect(new_order_item).must_respond_to field
        expect(@item_one).must_respond_to field
      end
    end
  end

  describe "relationships" do
    it "must have one order and product" do
      expect(@item_one.product).must_be_kind_of Product
      expect(@item_one.order).must_be_kind_of Order
    end

    it "cannot not have a order" do
      order_item.order = nil
      order_item.save
      expect(order_item.save).must_equal false
    end

    it "cannot not have a product" do
      order_item.product = nil
      order_item.save
      expect(order_item.save).must_equal false
    end
  end

  describe "validations" do
    it "must an order" do
      order_item.order = nil

      expect(order_item.valid?).must_equal false
      expect(order_item.errors.messages).must_include :order
      expect(order_item.errors.messages[:order]).must_equal ["must exist", "can't be blank"]
    end

    it "must have a product" do
      order_item.product = nil

      expect(order_item.valid?).must_equal false
      expect(order_item.errors.messages).must_include :product
      expect(order_item.errors.messages[:product]).must_equal ["must exist", "can't be blank"]
    end

    it "must have a quantity" do
      order_item.quantity = nil

      expect(order_item.valid?).must_equal false
      expect(order_item.errors.messages).must_include :quantity
      expect(order_item.errors.messages[:quantity]).must_equal ["can't be blank", "is not a number"]
    end

    it "must have a quantity > 0" do
      order_item.quantity = 0

      expect(order_item.valid?).must_equal false
      expect(order_item.errors.messages).must_include :quantity
      expect(order_item.errors.messages[:quantity]).must_equal ["must be greater than 0"]
    end

    it "must have a quantity that is a number" do
      order_item.quantity = "a"

      expect(order_item.valid?).must_equal false
      expect(order_item.errors.messages).must_include :quantity
      expect(order_item.errors.messages[:quantity]).must_equal ["is not a number"]
    end
  end

  describe "custom tests" do
    describe "items_by_order_merchant" do
      it "get order items by order and merchant" do
        order_items_faker = OrderItem.items_by_order_merchant(@order_one.id, @merchant_faker.id)
        order_items_faker.each do |order_item|
          expect(order_item).must_be_kind_of OrderItem
          expect(order_item.order).must_equal @order_one
        end
      end

      it "return empty array if no order items by order and merchant" do
        order_items_faker = OrderItem.items_by_order_merchant(@order_two.id, @merchant_faker.id)
        expect(order_items_faker).must_be_empty
      end
    end

    describe "order_revenue" do
      it "calculate order revenue by order and merchant" do
        order_items_faker = OrderItem.items_by_order_merchant(@order_one.id, @merchant_faker.id)

        check_revenue = 0
        order_items_faker.each do |order_item|
          check_revenue = order_item.quantity * order_item.product.price
        end

        order_rev_faker = OrderItem.order_revenue(@order_one.id, @merchant_faker.id)
        expect(order_rev_faker).must_equal check_revenue
      end

      it "return 0 if no combination of that order and merchant" do
        order_rev_faker = OrderItem.order_revenue(@order_two.id, @merchant_faker.id)
        expect(order_rev_faker).must_equal 0
      end
    end
  end
end
