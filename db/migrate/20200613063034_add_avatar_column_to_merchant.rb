class AddAvatarColumnToMerchant < ActiveRecord::Migration[6.0]
  def change
    add_column :merchants, :avatar, :string
  end
end
