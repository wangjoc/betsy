class Product < ApplicationRecord
  has_many :order_items
  belongs_to :merchant
  has_many :reviews
  has_and_belongs_to_many :categories

  validates :name, presence: true, uniqueness: true
  validates :photo_url, presence: true, format: { with: /https:\/\/.*/, message: "Please enter a photo url beginning with 'https://'" }
  validates :price, presence: true, numericality: { greater_than: 0 }, format: { with: /^[0-9]*\.?[0-9]*/, multiline: true, message: "Please enter a price using numbers" }

  def self.by_merchant(id)
    products = Product.where(merchant_id: id)
    return products.reject{|product| prodcut.stock<1}
  end

  def self.by_category(id)
    category = Category.find_by(id: id)
    return category.products
  end

  def self.featured_products
    products = []

    Product.all.each do |product|
      if product.reviews.length > 0
        products << product
      end
    end
    featured = products.sort_by { |product| -product.avg_rating }
    return featured[0..[4, featured.length].min]
  end

  def avg_rating
    reviews = Review.where(product_id: self.id)
    ratings = reviews.map do |review|
      review.rating
    end
    if ratings.count > 0
      return (ratings.sum.to_f / ratings.count).round(2)
    end
  end

  def in_stock?
    return self.stock > 0
  end

  def self.most_recent
    return Product.all.sample(5)
  end

  def decrease_stock(quantity)
    if self.stock >= quantity
      self.stock -= quantity
      self.save
      return true
    else
      return false
    end
  end

end
