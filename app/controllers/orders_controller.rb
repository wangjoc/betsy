class OrdersController < ApplicationController
  before_action :find_order, only: [:show, :purchase, :cancel, :complete, :add_to_cart, :confirmation]

  # TODO - JW to figure out how to prevent people from seeing this page after order path has been submitted (something to do with session again?)
  def show    
    if @order.nil?
      redirect_to products_path
      flash[:warning] = "Nothing in cart, let's do some shopping first!"
      return
    end

    if session[:order_id].nil?
      redirect_to products_path
      flash[:warning] = "Cannot access somebody else's order!"
      session[:return_to] = products_path
      return
    elsif session[:order_id] != @order.id
      redirect_to order_path(session[:order_id])
      session[:return_to] = order_path(@order.id)
      return
    end
  end

  def receipt
    @order = Order.find_by(id: session[:order_id])
    session[:order_id] = nil
    session[:return_to] = products_path
  end

  def new
    if session[:shopping_cart].nil?
      redirect_to products_path
      return
    end
    
    @order = Order.new
    session[:return_to] = new_order_path
  end

  def create
    @order = Order.new(order_params) 

    # TODO - move to a helper method if we need to check for this more than once
    if session[:shopping_cart].nil? || session[:shopping_cart].empty?
      redirect_to products_path
      flash[:warning] = "Nothing in cart, let's do some shopping first!"
      return
    end

    if @order.save 
      session[:shopping_cart].each do |product_id, quantity|
        @order.order_items << OrderItem.new(
                                order_id: @order.id,
                                product_id: product_id,
                                quantity: quantity
                              )
      end

      session[:order_id] = @order.id

      redirect_to order_path(@order.id)
      flash[:success] = "Successfully added new order: #{view_context.link_to "#Order ID: #{@order.id}", purchase_path(@order.id) }"
      return
    else 
      render :new, status: :bad_request
      return
    end
  end

  def purchase
    if @order.status == "pending"
      @order.status = "paid"
    else
      flash[:warning] = "Order already completed/cancelled, cannot change status"
      redirect_to order_path(@order.id)
      return
    end

    if @order.save
      flash[:success] = "Thank you for your purchase!"
      # session[:order_id] = nil
      session[:shopping_cart] = nil
      redirect_to receipt_path
      return
    else
      render :new, status: :bad_request
      return
    end
  end

  def cancel
    @order.status = "cancel"

    if @order.save
      flash[:success] = "We're sorry to see you cancel. Please call ###.###.### if there is anything we can help with"
      session[:order_id] = nil
      redirect_to session.delete(:return_to)
      return
    else
      render :new, status: :bad_request
      return
    end
  end

  def complete

  end

  private

  def order_params
    return params.require(:order).permit(:buyer_name, :mail_address, :zip_code, :email_address, :cc_num, :cc_exp)
  end

  def find_order
    @order = Order.find_by(id: params[:id])
  end

end
