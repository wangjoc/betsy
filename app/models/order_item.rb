class OrderItem < ApplicationRecord
  belongs_to :product
  belongs_to :order

  # validates :order, presence: true

  def self.items_by_order_merchant(order_id, merch_id)
    return OrderItem.where(:order_id => order_id).joins(:product).where(:products => { :merchant_id => merch_id })
  end
end
