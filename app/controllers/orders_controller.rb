class OrdersController < ApplicationController
  before_action :fix_params, only: [:create]
  before_action :find_order, only: [:show, :purchase, :cancel, :complete, :add_to_cart, :confirm, :ship]
  before_action :require_login, only: [:show, :ship]

  def show
    if @order.nil?
      flash[:warning] = "This order does not exist"
      redirect_to dashboard_path
      return
    end

    if Order.contains_merchant?(@order.id, session[:merchant_id])
      @order_items = OrderItem.items_by_order_merchant(@order.id, session[:merchant_id])
      @order_revenue = OrderItem.order_revenue(@order.id, session[:merchant_id])
      session[:return_to] = order_path(@order.id)
    else
      redirect_to dashboard_path
      flash[:warning] = "You do not have any products on this order!"
      return
    end
  end

  def confirm
    @order = Order.find_by(id: session[:order_id])

    if @order.nil?
      redirect_to products_path
      flash[:warning] = "Cannot access somebody else's order!"
      return
    end

    @order_revenue = 0
    @order.order_items.each do |order_item|
      @order_revenue += order_item.product.price * order_item.quantity
    end

    # prevents customer from seeing confirmation page if they've already paid
    if @order.status == "pending"
      session[:return_to] = confirm_path
    else
      redirect_to session.delete(:return_to)
      flash[:warning] = "No payment, no receipt!"
      return
    end
  end

  def new
    if session[:shopping_cart].nil? || session[:shopping_cart].empty?
      flash[:warning] = "Nothing in cart, let's do some shopping first!"
      redirect_to products_path
      return
    end

    @order = Order.new
    session[:return_to] = new_order_path
  end

  def create
    if session[:shopping_cart].nil? || session[:shopping_cart].empty?
      flash[:warning] = "Nothing in cart, let's do some shopping first!"
      redirect_to products_path
      return
    end

    @order = Order.new(order_params)

    session[:shopping_cart].each do |product_id, quantity|
      product = Product.find_by(id: product_id)

      if product.stock < quantity
        flash[:warning] = "Sorry, looks like someone beat you to the punch. ##{product.id} #{product.name} does not have the quantity you're looking for."
        redirect_to products_path
        return
      end

      @order.order_items << OrderItem.new(
        product_id: product_id,
        quantity: quantity,
      )
    end

    if @order.save
      session[:shopping_cart] = nil
      session[:order_id] = @order.id
      session[:return_to] = products_path

      redirect_to confirm_path
      flash[:success] = "Thanks for creating an order! Please confirm your regrets to render payment."
      return
    else
      render :new, status: :bad_request
      return
    end
  end

  def purchase
    @order = Order.find_by(id: session[:order_id])

    if @order.status == "pending" || @order.status == "paid"
      @order.status = "paid"
    else
      flash[:warning] = "Order already completed/cancelled, cannot change status"
      redirect_to order_path(@order.id)
      return
    end

    if @order.save
      # reducing stock here because we don't want on order to go half way through but still have stock reduce
      @order.order_items.each do |order_item|
        order_item.product.decrease_stock(order_item.quantity)
      end

      flash[:success] = "Thank you for your purchase! Hope you regret it :)"
      session[:order_id] = @order.id
      session[:return_to] = products_path
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
      flash[:success] = "We're sorry to see you cancel. Please call ###.###.### if there is anything else we can make you regret."
      session[:order_id] = nil
      redirect_to session.delete(:return_to)
      return
    else
      render :new, status: :bad_request
      return
    end
  end

  def receipt
    if session[:order_id].nil?
      redirect_to products_path
      flash[:warning] = "Cannot access somebody else's order!"
      return
    end

    @order = Order.find_by(id: session[:order_id])
    # TODO move to helper method?

    @order_revenue = 0
    @order.order_items.each do |order_item|
      @order_revenue += order_item.product.price * order_item.quantity
    end

    # prevent customer from seeing receipt if they haven't paid yet
    if @order.status == "paid"
      session[:order_id] = nil
      session[:return_to] = products_path
    else
      redirect_to session.delete(:return_to)
      flash[:warning] = "No payment, no receipt!"
      return
    end
  end

  def ship
    @order_items = OrderItem.items_by_order_merchant(@order.id, session[:merchant_id])

    @order_items.each do |order_item|
      item = order_item
      item.is_shipped = true
      item.save
    end

    redirect_to session.delete(:return_to)
  end

  private

  def order_params
    return params.require(:order).permit(:buyer_name, :mail_address, :zip_code, :email_address, :cc_num, :cc_exp, :cc_cvv)
  end

  def fix_params
    # https://stackoverflow.com/questions/47932187/combining-two-form-input-into-one-db-entry
    month = params[:order].delete(:month)
    year = params[:order].delete(:year)

    if month == "" || year == ""
      params[:order][:cc_exp] = "#{month}#{year}"
    else
      params[:order][:cc_exp] = "%02d" % month + "%02d" % year
    end

    cc_num = (params[:order].delete(:cc_one) +
              params[:order].delete(:cc_two) +
              params[:order].delete(:cc_three))

    params[:order][:cc_num] = cc_num.gsub(/\d/, "*") + params[:order][:cc_four]

    params[:order][:cc_cvv] = params[:order][:cc_cvv].gsub(/\d/, "*")
  end

  def find_order
    @order = Order.find_by(id: params[:id])
  end
end
