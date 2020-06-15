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

  # TODO - there might be a way to get the data through a query (more  efficient). Might need to reset the relationship between the two tables
  def self.by_category(id)
    products = []
    Product.all.each do |product|
      products << product if product.category_ids.include? id
    end
    return products
  end

  def self.featured_products
    #     Video.group(:id).average(:available_inventory)
    # New
    # 3:14
    # Rating.group(:product_id).average(:score).order(:score)
    # after_save
    # https://guides.rubyonrails.org/active_record_callbacks.html
    # TODO: just taking the bottom three off the list for now, can implement other logic later
    return Product.order("id DESC")[0..[Merchant.all.length, 2].min]
  end

  def reduce_stock
    @product = Product.find(params[:id])

    if @product.stock >= 1
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
