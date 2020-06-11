class Product < ApplicationRecord
  has_many :order_items
  belongs_to :merchant

  validates :name, presence: true, uniqueness: true

  def self.by_merchant(id)
    products = Product.where("id > ?", 1) 
    m_products = []
    products.each do |product|
      if Product.find_by(id: product.id).merchant_id == id.to_i
        result << product
      end
    end
    return m_products
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
