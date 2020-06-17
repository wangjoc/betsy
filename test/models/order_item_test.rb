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
      # order_items: [order_item],
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
    @merchant_faker = merchants(:faker)
    # @merchant_greentye = merchants(:greentye)
    # @merchant_dancingrain = merchants(:dancingrain)
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
end
