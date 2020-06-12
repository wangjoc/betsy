class Product < ApplicationRecord
  has_many :order_items
  belongs_to :merchant
  has_many :reviews
  has_and_belongs_to_many :categories

  validates :name, presence: true, uniqueness: true
  validates :description, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :photo_url, presence: true
  validates :stock, presence: true, numericality: { only_integer: true, greater_than: -1 }
  validates :merchant_id, presence: true

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

  # TODO - there might be a way to get the data through a query (more  efficient). Might need to reset the relationship between the two tables
  def self.by_category(id)
    products = []
    Product.all.each do |product|
      products << product if product.category_ids.include? id 
    end
    return products
  end

  def self.categorize_by_category
    cat_by_category = {}
    Category.all.each do |category|
      cat_by_category[category.id] = by_category(category.id)
    end
    return cat_by_category
  end

  def self.featured_products
    # TODO: just taking the bottom three off the list for now, can implement other logic later
    return Product.order('id DESC')[0..2]
    def self.sample_products_for_homepage()
      product_list = Product.order(Arel.sql("RANDOM()")).to_a
      
      sample_products_list = []
      
      while sample_products_list.length < 5 && !product_list.empty?
        product = product_list.pop()
        
        if product.available == true
          sample_products_list << product
        end
      end
      
      return sample_products_list
    end
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

  def rating_average
    if self.reviews.count > 0
      (self.reviews.map{ |review| review.rating }.sum / self.reviews.count.to_f).round(1)
    end
  end

  def self.sort_products
    return Product.order(name: :asc)
  end

end

end
