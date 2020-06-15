class AddShippedStatusColumn < ActiveRecord::Migration[6.0]
  def change
    add_column :order_items, :is_shipped, :boolean, default: false
  end
end
