class Product < ApplicationRecord
  has_many :order_items
  belongs_to :merchant
  has_many :reviews
  has_and_belongs_to_many :categories

  validates :name, presence: true, uniqueness: true
  validates :photo_url, presence: true, format: { with: /https:\/\/.*/, message: "Please enter a photo url beginning with 'https://'" }
  validates :price, presence: true, numericality: { greater_than: 0 }, format: { with: /^[0-9]*\.?[0-9]*/, multiline: true, message: "Please enter a price using numbers" }

  def self.by_merchant(id)
    # products = Product.where("id > ?", 1)
    return Product.where(merchant_id: id)
  end

  # TODO - there might be a way to get the data through a query (more  efficient). Might need to reset the relationship between the two tables
  def self.by_category(id)
    category = Category.find_by(id: id)
    return category.products.uniq
    # products = []
    # self.all.each do |product|
    #  if product.category_ids.include?(id)
    #   products<< product
    #  end
    # end
    # return products
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
      return (ratings.sum / ratings.count)
    end
  end

  def in_stock?
    return self.stock > 0
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

  def retire_product(id)
    product = Product.find_by(id: id)
    product.stock = 0
  end
end
