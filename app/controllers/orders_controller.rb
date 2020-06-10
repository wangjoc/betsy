class OrdersController < ApplicationController
  def index
    @orders = Order.all
  end

  def new
    @order = Order.new
  end

  def create
    @order = Order.new(order_params) 

    if @order.save 
      Order.first.order_items.each do |order_items|
        @order.order_items << order_items
      end

      redirect_to order_path(@order.id)
      flash[:success] = "Successfully added new order: #{view_context.link_to "#Order ID: #{@order.id}", order_path(@order.id) }"
      return
    else 
      render :new, status: :bad_request
      return
    end
  end

  private

  def order_params
    return params.require(:order).permit(:buyer_name, :mail_address, :zip_code, :email_address, :cc_num, :cc_exp)
  end

end
