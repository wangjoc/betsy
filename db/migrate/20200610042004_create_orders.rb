class CreateOrders < ActiveRecord::Migration[6.0]
  def change
    create_table :orders do |t|
      t.string :status, :default => "pending"
      t.string :buyer_name
      t.string :email_address
      t.string :mail_address
      t.string :zip_code
      t.integer :cc_num
      t.integer :cc_exp

      t.timestamps
    end
  end
end
