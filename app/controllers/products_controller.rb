class ProductsController < ApplicationController
  before_action :find_product, only: [:show, :edit, :update, :retire, :add_to_cart, :remove_from_cart, :delete_from_cart]
  before_action :require_login, only: [:new, :create, :edit, :update]

  def index
    @products = Product.where("stock > ?", 0)
    session[:return_to] = products_path
  end

  def show
    if @product.nil?
      redirect_to products_path
      return
    end

    @reviews = Review.where(product_id: @product.id)
    @featured_products = Product.featured_products

    session[:return_to] = product_path(@product.id)
  end

  def new
    @product = Product.new
  end

  def create
    @product = Product.new(product_params)

    if @product.save
      flash[:success] = "Successfully added new product: #{view_context.link_to "##{@product.id} #{@product.name}", product_path(@product.id)}"
      redirect_to product_path(@product.id)
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

    if session[:merchant_id] != @product.merchant.id
      flash[:warning] = "Cannot edit another merchant's products"
      redirect_to dashboard_path
      return
    end
  end

  def update
    if @product.nil?
      head :not_found
      return
    elsif @product.update(product_params)
      flash[:success] = "Successfully edited new product: #{view_context.link_to "##{@product.id} #{@product.name}", product_path(@product.id)}"
      redirect_to product_path(@product.id)
      return
    else
      render :edit, status: :bad_request
      return
    end
  end

  def retire
    if @product.update(stock: 0)
      flash[:success] = "Successfully retired product"
      redirect_to dashboard_path
    else
      flash[:failure] = "Couldn't retire product!"
      redirect_to dashboard_path
    end
  end

  def add_to_cart
    if @product.nil?
      head :not_found
      return
    end

    if session[:shopping_cart].nil?
      session[:shopping_cart] = Hash.new()
    end

    # TODO - JW to clean this up and make it more manageable
    if session[:shopping_cart][@product.id.to_s]
      if session[:shopping_cart][@product.id.to_s] < @product.stock
        session[:shopping_cart][@product.id.to_s] += 1
        flash[:success] = "You have added a #{view_context.link_to "#{@product.name}", product_path(@product.id)} to the cart!"
      else
        flash[:warning] = "Sorry, no more stock for #{view_context.link_to "#{@product.name}", product_path(@product.id)}!"
      end
    else
      if @product.stock > 0
        session[:shopping_cart][@product.id.to_s] = 1
        flash[:success] = "You have added a #{view_context.link_to "#{@product.name}", product_path(@product.id)} to the cart!"
      else
        flash[:warning] = "Sorry, no more stock for #{view_context.link_to "#{@product.name}", product_path(@product.id)}!"
      end
    end

    redirect_to session.delete(:return_to)
    return
  end

  def remove_from_cart
    if @product.nil?
      head :not_found
      return
    end

    if session[:shopping_cart].nil?
      session[:shopping_cart] = Hash.new()
    end

    if session[:shopping_cart][@product.id.to_s] && session[:shopping_cart][@product.id.to_s] > 0
      session[:shopping_cart][@product.id.to_s] -= 1
      flash[:success] = "You have removed a #{view_context.link_to "#{@product.name}", product_path(@product.id)} from the cart!"
      if session[:shopping_cart][@product.id.to_s] == 0
        session[:shopping_cart].delete(@product.id.to_s)
        flash[:warning] = "#{view_context.link_to "#{@product.name}", product_path(@product.id)} has been fully removed from the cart."
      end
    else
      flash[:warning] = "#{view_context.link_to "#{@product.name}", product_path(@product.id)} is not in the cart."
    end

    redirect_to session.delete(:return_to)
    return
  end

  def delete_from_cart
    if @product.nil?
      head :not_found
      return
    end

    session[:shopping_cart].delete(@product.id.to_s)
    flash[:warning] = "#{view_context.link_to "#{@product.name}", product_path(@product.id)} has been fully removed from the cart."
    redirect_to session.delete(:return_to)
    return
  end

  private

  def product_params
    complete_params = params.require(:product).permit(:name, :description, :price, :stock, :photo_url, category_ids: [])
    complete_params[:merchant_id] = session[:merchant_id]
    return complete_params
  end

  def find_product
    @product = Product.find_by(id: params[:id])
  end
end
