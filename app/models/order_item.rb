class OrderItem < ApplicationRecord
  belongs_to :product
  belongs_to :order

  validates :order, presence: true
  validates :product, presence: true
  validates :quantity, presence: true, numericality: { greater_than: 0, only_integer: true }

  def self.items_by_order_merchant(order_id, merch_id)
    return OrderItem.order("id").where(:order_id => order_id).joins(:product).where(:products => { :merchant_id => merch_id })
  end

  def self.order_revenue(order_id, merch_id)
    order_items = items_by_order_merchant(order_id, merch_id)
    revenue = 0

    order_items.each do |order_item|
      revenue += order_item.product.price * order_item.quantity
    end

    return revenue
  end
end
