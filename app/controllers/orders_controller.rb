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
      redirect_to order_path(@order.id)
      flash[:success] = "Successfully added new order: #{view_context.link_to "##{@order.id} #{@order.title}", order_path(@order.id) }"
      return
    else 
      render :new, status: :bad_request
      return
    end
  end

  private

  def order_params
    return params.require(:order).permit(:status)
  end

end
