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
    return Merchant.order('id DESC')[0..1]
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

