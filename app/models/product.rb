class Product < ApplicationRecord
  has_many :order_items
  belongs_to :merchant
  has_many :reviews
  has_and_belongs_to_many :categories

  validates :name, presence: true, uniqueness: true

  def self.by_merchant(id)
    # products = Product.where("id > ?", 1) 
    return Product.where(merchant_id: id)
  end

  def self.categorize_by_merchant
    cat_by_merchant = {}
    Merchant.all.each do |merchant|
      cat_by_merchant[merchant.id] = by_merchant(merchant.id)
    end
    return cat_by_merchant
  end

  def reduce_stock
    @product = Product.find(params[:id])
    
    if @product.stock >=1
        @product.stock -= 1
        flash[:success] = "Successfully updated #{view_context.link_to @product.name, product_path(@product.id)}" 
        redirect_to order_path(@order.id)
        return
    else 
        render :show, status: :bad_request 
        return
    end
  end

end
