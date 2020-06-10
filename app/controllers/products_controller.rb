class ProductsController < ApplicationController
  before_action :find_product, only: [:show, :edit, :update]
  
  def index
    @products = Product.all
  end

  def show    
    if @product.nil?
      redirect_to products_path
      return
    end
  end

  def new
    @product = Product.new
  end

  def create
    @product = Product.new(product_params) 

    if @product.save 
      redirect_to product_path(@product.id)
      flash[:success] = "Successfully added new product: #{view_context.link_to "##{@product.id} #{@product.name}", product_path(@product.id) }"
      return
    else 
      render :new, status: :bad_request
      return
    end
  end

  def edit
    if @product.nil?
      head :not_found
      return
    end
  end

  def update
    if @product.nil?
      head :not_found
      return
    elsif @product.update(product_params)
      flash[:success] = "Successfully edited #{view_context.link_to @product.name, product_path(@product.id)}" 
      redirect_to product_path(@product.id)
      return
    else 
      render :edit, status: :bad_request 
      return
    end
  end

  private

  def product_params
    complete_params = params.require(:product).permit(:name, :description, :price, :stock, :photo_url)
    complete_params[:merchant_id] = session[:merchant_id]
    return complete_params
  end

  def find_product
    @product = Product.find_by(id: params[:id])
  end

end
