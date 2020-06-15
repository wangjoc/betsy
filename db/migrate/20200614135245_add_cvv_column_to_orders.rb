class AddCvvColumnToOrders < ActiveRecord::Migration[6.0]
  def change
    add_column :orders, :cc_cvv, :string
  end
end
