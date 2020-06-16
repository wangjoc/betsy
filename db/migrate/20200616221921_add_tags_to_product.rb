class AddTagsToProduct < ActiveRecord::Migration[6.0]
  def change
    add_column :products, :tags, :string
  end
end
