class Order < ApplicationRecord
  has_many :order_items

  validates :buyer_name, presence: true
  validates :email_address, presence: true
  validates_format_of :email_address, :with => /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/
  validates :mail_address, presence: true
  validates :zip_code, presence: true, numericality: true, length: { is: 5 }

  validates :cc_num, presence: true, length: { is: 16 }
  validates_format_of :cc_num, :with => /\*{12}\d{4}/
  validates :cc_exp, presence: true, length: { is: 4 }
  validates_format_of :cc_exp, :with => /\d{4}/
  validates :cc_cvv, presence: true, length: { is: 3 }
  validates_format_of :cc_cvv, :with => /\*{3}/
  validates :order_items, presence: true

  def self.contains_merchant?(order_id, merch_id)
    # query checks to see if the order contains the merchant
    return !Order.where(:id => order_id).joins(:order_items => :product).where(:products => { :merchant_id => merch_id }).empty?
  end

  def total_price_for_merchant(merchant_id)
    order_items.joins(:product).where(products: { merchant_id: merchant_id }).reduce(0) do |sum, item|
      sum + item.product.price * item.quantity
    end
  end

  def total_price_for_merchant(merchant_id)
    order_items.joins(:product).where(products: { merchant_id: merchant_id }).reduce(0) do |sum, item|
      sum + item.product.price * item.quantity
    end
  end
end
