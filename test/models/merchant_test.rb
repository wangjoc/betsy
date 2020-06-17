require "test_helper"

describe Merchant do
  let (:new_product) {
    Product.new(
      name: "Thousand Chance Umbrella",
      description: "Ultimate weapon (silver grade). Makes the unspecialized class feasible.",
      price: 1000,
      photo_url: "https://imgur.com/wC1RZzd",
      stock: 5,
    )
  }

  let (:new_merchant) {
    Merchant.new(
      provider: "github",
      uid: "11111111",
      name: "Bao Rong Xing",
      email: "steamedbuninvasion@glory.com",
      avatar: "https://imgur.com/Q6snmV7.jpg",
    )
  }

  before do
    @merchant_faker = merchants(:faker)
    @merchant_greentye = merchants(:greentye)
  end

  describe "instantiation" do
    it "can be instantiated" do
      expect(new_merchant.valid?).must_equal true
      expect(@merchant_faker.valid?).must_equal true
      expect(@merchant_greentye.valid?).must_equal true
    end

    it "will have the required fields" do
      new_merchant.save
      merchant = Merchant.last
      [:provider, :uid, :name, :email, :avatar].each do |field|
        expect(new_merchant).must_respond_to field
        expect(@merchant_faker).must_respond_to field
      end
    end
  end

  # https://stackoverflow.com/questions/34981661/creating-two-objects-in-one-controller-and-attaching-them-to-each-other-in-rails
  describe "relationships" do
    before do
      new_merchant.save
      @merchant = Merchant.last
    end

    it "can have no products" do
      expect(@merchant.products).must_be_empty
    end

    it "can have products" do
      expect(@merchant.products.length).must_equal 0

      new_product.merchant = @merchant
      new_product.save

      expect(Merchant.last.products.length).must_equal 1
      Merchant.last.products.each do |product|
        expect(product).must_be_instance_of Product
      end
    end
  end

  describe "validations" do
    it "must have a provider" do
      new_merchant.provider = nil

      expect(new_merchant.valid?).must_equal false
      expect(new_merchant.errors.messages).must_include :provider
      expect(new_merchant.errors.messages[:provider]).must_equal ["can't be blank"]
    end

    it "must have a uid" do
      new_merchant.uid = nil

      expect(new_merchant.valid?).must_equal false
      expect(new_merchant.errors.messages).must_include :uid
      expect(new_merchant.errors.messages[:uid]).must_equal ["can't be blank"]
    end

    it "must have a uid" do
      new_merchant.uid = nil

      expect(new_merchant.valid?).must_equal false
      expect(new_merchant.errors.messages).must_include :uid
      expect(new_merchant.errors.messages[:uid]).must_equal ["can't be blank"]
    end

    it "must have unique uid" do
      new_merchant.uid = Merchant.last.uid
      result = new_merchant.save

      expect(result).must_equal false
    end

    it "must have a merchant name" do
      new_merchant.name = nil

      expect(new_merchant.valid?).must_equal false
      expect(new_merchant.errors.messages).must_include :name
      expect(new_merchant.errors.messages[:name]).must_equal ["can't be blank"]
    end

    it "must have a email address" do
      new_merchant.email = nil

      expect(new_merchant.valid?).must_equal false
      expect(new_merchant.errors.messages).must_include :email
      expect(new_merchant.errors.messages[:email]).must_equal ["can't be blank", "is invalid"]
    end

    it "must have unique email" do
      new_merchant.email = Merchant.last.email
      result = new_merchant.save

      expect(result).must_equal false
    end

    it "must have a valid email address" do
      new_merchant.email = "troublingrain"

      expect(new_merchant.valid?).must_equal false
      expect(new_merchant.errors.messages).must_include :email
      expect(new_merchant.errors.messages[:email]).must_equal ["is invalid"]
    end

    it "must have a avatar" do
      new_merchant.avatar = nil

      expect(new_merchant.valid?).must_equal false
      expect(new_merchant.errors.messages).must_include :avatar
      expect(new_merchant.errors.messages[:avatar]).must_equal ["can't be blank"]
    end
  end

  describe "custom tests" do
    describe "get_merchant_order_items" do
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

      it "returns empty array if merchant doesn't exist" do
        expect(Merchant.get_merchant_orders(-1)).must_be_empty
      end
    end

    describe "get_merchant_orders" do
      it "get all of a merchant's orders" do
        order_item_count = 0
        Merchant.all.each do |merchant|
          Merchant.get_merchant_orders(merchant.id).each do |order|
            expect(order).must_be_instance_of Order

            order.order_items.each do |order_item|
              if order_item.product.merchant == merchant
                order_item_count += 1
                expect(order_item).must_be_instance_of OrderItem
              end
            end
          end
        end
        expect(OrderItem.all.length).must_equal order_item_count
      end

      it "returns empty array if merchant doesn't exist" do
        expect(Merchant.get_merchant_orders(-1)).must_be_empty
      end
    end

    describe "featured_merchants" do
      it "orders merchants by most order_items sold (two merchants with orders sold)" do
        merchant_order = {}
        Merchant.all.each do |merchant|
          merchant_order[merchant.id] = Merchant.get_merchant_order_items(merchant.id).size
        end

        sorted = merchant_order.sort_by { |k, v| v }.reverse
        featured_sort = Merchant.featured_merchants

        expect(featured_sort[0].id).must_equal sorted[0][0]
        expect(featured_sort[1].id).must_equal sorted[1][0]
      end

      it "returns empty array if there are no merchants" do
        Merchant.delete_all
        featured_sort = Merchant.featured_merchants

        expect(featured_sort).must_be_empty
      end

      it "returns empty array if there no merchants have sold anything" do
        OrderItem.delete_all
        featured_sort = Merchant.featured_merchants

        expect(featured_sort).must_be_empty
      end
    end

    describe "newest_merchants" do
      it "orders merchants by newest added" do
        merchant_order = {}
        Merchant.all.each do |merchant|
          merchant_order[merchant.id] = merchant.created_at
        end

        sorted = merchant_order.sort_by { |k, v| v }
        newest_sort = Merchant.newest_merchants

        expect(newest_sort[0].id).must_equal sorted[0][0]
        expect(newest_sort[1].id).must_equal sorted[1][0]
        expect(newest_sort[2].id).must_equal sorted[2][0]
      end

      it "returns empty array if there are no merchants" do
        Merchant.delete_all
        newest_sort = Merchant.newest_merchants

        expect(newest_sort).must_be_empty
      end
    end
  end

  describe "cusomer methods" do
    before do
      @merchant = merchants(:order_status_merchant)
    end

    describe "orders of status" do
      it "return order of status :pending" do
        order_array = @merchant.orders_of_status(:pending)
        expect(order_array.size).must_equal 1
        order = order_array[0]
        expect(order.status).must_equal "pending"
        expect(order.order_items.size).must_equal 1
        expect(order.order_items[0].quantity).must_equal 1
      end

      it "return orders of status :shipped" do
        order_array = @merchant.orders_of_status(:shipped)
        expect(order_array.size).must_equal 1
        order = order_array[0]
        expect(order.status).must_equal "shipped"
        expect(order.order_items.size).must_equal 1
        expect(order.order_items[0].quantity).must_equal 2
      end

      it "return orders of status :paid" do
        order_array = @merchant.orders_of_status(:paid)
        expect(order_array.size).must_equal 1
        order = order_array[0]
        expect(order.status).must_equal "paid"
        expect(order.order_items.size).must_equal 1
        expect(order.order_items[0].quantity).must_equal 3
      end

      it "return orders of status :cancel" do
        order_array = @merchant.orders_of_status(:cancel)
        expect(order_array.size).must_equal 1
        order = order_array[0]
        expect(order.status).must_equal "cancel"
        expect(order.order_items.size).must_equal 1
        expect(order.order_items[0].quantity).must_equal 4
      end
    end

    describe "revenue of status" do
      it "count the total price of :pending order" do
        pending_revenue = @merchant.revenue_of_status(:pending)
        pending_revenue.must_equal() #do the math
      end

      it "counts the total price of :shipped order" do
        shipped_revenue = @merchant.revenue_of_status(:shipped)
        shipped_revenue.must_equal() #do math
      end
    end

    describe "order count" do
      it "return the correct count of :pending orders" do
        pending_orders = @merchant.order_count(:pending)
        pending_orders.must_equal() # do the math
      end

      it "return the correct count of :shipped orders" do
        shipped_orders = @merchant.order_count(:shipped)
        shipped_orders.must_equal 0
      end
    end

    describe "total revenue" do
      it "return the correct amount of total revnue" do
        total_revneue = @merchant.total_revneue
        total_revneue.must_equal() # do math
      end
    end
  end
end
