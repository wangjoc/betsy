class Merchant < ApplicationRecord
  has_many :products

  # TODO - if we were to allow more than OAuth method, might need to verify that uid + provider is the unique value (ie. two diff account from google and github might have same uid)
  validates :provider, presence: true
  validates :uid, presence: true, uniqueness: true
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates_format_of :email, :with => /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/  
  validates :avatar, presence: true

  def self.build_from_github(auth_hash)
    merchant = Merchant.new
    merchant.uid = auth_hash[:uid]
    merchant.provider = "github"
    merchant.name = auth_hash["info"]["name"] || auth_hash["info"]["nickname"]
    merchant.email = auth_hash["info"]["email"]
    merchant.avatar = auth_hash["info"]["image"]
    return merchant  
  end

  def self.get_merchant_order_items(id)
    return OrderItem.joins(:product).where(:products => {:merchant_id => id})
  end

  # https://stackoverflow.com/questions/19527177/rails-triple-join
  def self.get_merchant_orders(id)
    return Order.order('id').joins(:order_items => :product).where(:products => {:merchant_id => id}).uniq
  end

  def self.featured_merchants
    # Sorts by order_item count (most order_items at the top)
    return Merchant.joins(:products => :order_items).group(:id).order('COUNT(order_items.id) DESC')[0..[Merchant.all.length,2].min]
     
    # TODO - If we have time, try to figure out how to sort by orderitem quantity instead, and by paid orders
    # Merchant.joins(:products => :order_items).group(:id).order('COUNT(quantity) DESC')
  end

  def self.newest_merchants
    # Sorts by newest added merchants
    return  Merchant.order('created_at DESC')[0..[Merchant.all.length,2].min]
  end

  def orders_of_status(status)
    Order.joins(order_items: :product).where(orders: {status: status}, products: {merchant_id: id}) 
  end

  def revenue_of_status(status)
    orders = orders_of_status(status)
    orders.reduce(0) do |sum, order|
      sum + order.total_price_for_merchant(id)
    end
  end

  def order_count(status)
    orders_of_status(status).count
  end

  def total_revenue
   revenue_of_status(:paid) + revenue_of_status(:shipped) 
  end
end

