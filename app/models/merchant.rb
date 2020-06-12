class Merchant < ApplicationRecord
  has_many :products

  validates :name, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true
  validates_format_of :email, :with => /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/

  def self.build_from_github(auth_hash)
    merchant = Merchant.new
    merchant.uid = auth_hash[:uid]
    merchant.provider = "github"
    merchant.name = auth_hash["info"]["name"] || auth_hash["info"]["nickname"]
    merchant.email = auth_hash["info"]["email"]
    return merchant
  end

  def self.featured_merchants
    # TODO: just taking the bottom three off the list for now, can implement other logic later
    return Merchant.order("id DESC")[0..2]
  end

  def orders_of_status(status)
    OrderProduct.where(status: status).joins(:product).merge(Product.where(merchant_id: id))
  end

  def revenue_of_status(status)
    order_products = orders_of_status(status)
    sum = 0
    order_products.each do |order|
      sum += order.total_price
    end
    return sum
  end

  def order_count(status)
    order_products = orders_of_status(status)
    return order_products.count
  end

  def total_revenue
    return revenue_of_status(:pending) + revenue_of_status(:shipped)
  end
end
