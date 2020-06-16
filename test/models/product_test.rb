require "test_helper"

describe Product do
  describe "validations" do
    describe "name validation" do
      it "is invalid without a title" do
        product = products(:diaper)
        product.name = nil

        # Act
        result = product.valid?

        # Assert
        expect(result).must_equal false
      end
      it "is valid with a name" do
        product = products(:diaper)
        product.name = "Used Diaper"

        # Act
        result = product.valid?

        # Assert
        expect(result).must_equal true
      end
    end
    describe "price validation" do
      it "is invalid without a price" do
        product2 = products(:toilet)
        product2.price = nil

        # Act
        result = product2.valid?

        # Assert
        expect(result).must_equal false
      end
      it "is invalid with a non-numerical price" do
        product2 = products(:toilet)
        product2.price = "no price"

        # Act
        result = product2.valid?

        # Assert
        expect(result).must_equal false
      end

      it "is invalid with a price of 0" do
        product2 = products(:toilet)
        product2.price = 0

        # Act
        result = product2.valid?

        # Assert
        expect(result).must_equal false
      end

      it "is invalid with a price less than 0" do
        product2 = products(:toilet)
        product2.price = -6.25

        # Act
        result = product2.valid?

        # Assert
        expect(result).must_equal false
      end

      it "is valid with a numerical price greater than 0" do
        product2 = products(:toilet)
        product2.price = 1.09

        # Act
        result = product2.valid?

        # Assert
        expect(result).must_equal true
      end
    end
    describe "photo_url valdation" do
      it "is invalid without a 'https' in the url" do
        product3 = products(:lion)
        product3.photo_url = "www.com"

        # Act
        result = product3.valid?

        # Assert
        expect(result).must_equal false
      end
      it "is valid with a 'https' in the url" do
        product3 = products(:lion)
        product3.photo_url = "https://www.com"

        # Act
        result = product3.valid?

        # Assert
        expect(result).must_equal true
      end
    end
  end

  describe "relations" do
    describe "product relationships" do
      it "can get the merchant through merchant" do
        current_product = products(:diaper)
        expect(current_product.merchant).must_be_instance_of Merchant
      end
    end

    it "has a merchant" do
      merchant = Merchant.first
      
      product = Product.create(name: "product", price: 599.99,photo_url: "https://i.imgur.com/JWfZcrG.jpg",  stock: 5, merchant: merchant)
      
      expect(product).must_respond_to :merchant
      expect(product.merchant).must_be_kind_of Merchant
    end
    
    it "has a category" do
      product = products(:diaper)
      
      expect(product).must_respond_to :categories
      product.categories.each do |category|
        expect(category).must_be_kind_of Category
      end
    end
    
    it "contains many order items" do
      product = products(:lion)
      
      expect(product.order_items.count).must_equal 2
      expect(product).must_respond_to :order_items
      product.order_items.each do |order_item|
        expect(order_item).must_be_kind_of OrderItem
      end
    end
    
    it "can contain many reviews" do
      product = products(:lion)
      
      expect(product.reviews.count).must_equal 1
      expect(product).must_respond_to :reviews
      product.reviews.each do |review|
        expect(review).must_be_kind_of Review
      end
    end
  end
  
  describe "custom methods" do 
    describe "list of products by category" do
      it "returns a list of products for each category" do
        category = categories(:indoor)
        product = products(:lion)
        product.categories<< category
        products = Product.by_category(category.id)
        expect(products.count).must_equal 2
      end
    end
  
    describe "in_stock?" do
      it "returns true if given a valid product that has items in stock" do
        product = products(:lion)
        expect(product.in_stock?).must_equal true
      end
  
      it "returns false if the current product is out of stock" do
        product = products(:toilet)
        product.stock = 0
        expect(product.in_stock?).must_equal false
      end
    end
    
    it "calculate the average rating of a product with reviews" do
      product = products(:lion)
      
      expect(product.avg_rating).must_equal 3
    end
    
    it "creates a list of featured products" do
      products = Product.featured_products

      p products
      
      expect(products).must_be_kind_of Array
      expect(products.first.name).must_equal products(:lion).name
    end
  end

  describe "decrease_stock" do
    it "decreases the given product's stock by the given quantity" do
      product = products(:toilet)
      expect(product.stock).must_equal 1

      expect(product.decrease_stock(1)).must_equal true
      expect(product.stock).must_equal 0
    end

    it "does not decrease the stock if it is already 0 and returns false" do
      product = products(:lion)
      product.stock = 0
      expect(product.stock).must_equal 0

      expect(product.decrease_stock(1)).must_equal false
      expect(product.stock).must_equal 0
    end
  end

  # describe "increase_stock" do
  #   it "increases the given product's stock by the given quantity" do
  #     product = products(:lion)
  #     expect(product.stock).must_equal 2

  #     product.increase_stock(2)
  #     expect(product.stock).must_equal 4
  #   end
  # end

end
