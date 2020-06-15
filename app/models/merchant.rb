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
    return Order.joins(:order_items => :product).where(:products => {:merchant_id => id}).uniq
  end

  def self.featured_merchants
    # TODO: just taking the bottom three off the list for now, can implement other logic later
    return Merchant.order('id DESC')[0..[Merchant.all.length,2].min]
  end



  
  def orders_of_status(status)
    # something goes here
    end
  
    def revenue_of_status(status)
      #some logic goes here for sum and total price
  
    end
  
    def order_count(status)
      #logic goes here
    end
  
    def total_revenue
      return revenue_of_status(:pending) + revenue_of_status(:shipped)
    end

  
  end

