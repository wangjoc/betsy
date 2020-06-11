class OrdersController < ApplicationController
  before_action :find_work, only: [:show, :purchase, :add_to_cart]

  def index
    @orders = Order.all
  end

  def new
    @order = Order.new
    session[:return_to] = new_order_path
  end

  def show    
    if @order.nil?
      redirect_to orders_path
      return
    end

    session[:return_to] = order_path(@order.id)
  end

  def create
    @order = Order.new(order_params) 

    if @order.save 
      OrderItem.all.each do |order_items|
        @order.order_items << order_items
      end

      redirect_to purchase_path(@order.id)
      flash[:success] = "Successfully added new order: #{view_context.link_to "#Order ID: #{@order.id}", purchase_path(@order.id) }"
      return
    else 
      render :new, status: :bad_request
      return
    end
  end

  def purchase

  end

  def complete

  end

  # def add_to_cart
  #   # user = current_user

  #   if @product.nil? 
  #     head :not_found
  #     return
  #   end

  #   if @product.stock > 0
  #     if session[:shopping_cart][@product.id] 
  #       session[:shopping_cart][@product.id] += 1
  #       @product.stock -= 1
  #     else
  #       session[:shopping_cart][@product.id] = 1
  #     end
  #     flash[:success] = "You have successfully added on to the cart!"
  #   else
  #     flash[:warning] = "Sorry, this product is currently out of stock!"
  #   end


  #   # if user.works.include? @work
  #   #   flash[:warning] = "You have already voted on #{view_context.link_to @work.title, work_path(@work.id)}!"
  #   # else
  #   #   new_vote = Vote.new(user_id: user.id, work_id: @work.id)

  #   #   if new_vote.save
  #   #     flash[:success] = "You have successfully voted on #{view_context.link_to @work.title, work_path(@work.id)}!"
  #   #   else
  #   #     render :new, status: :bad_request
  #   #     return
  #   #   end
  #   # end

  #   redirect_to session.delete(:return_to)
  #   return
  # end

  private

  def order_params
    return params.require(:order).permit(:buyer_name, :mail_address, :zip_code, :email_address, :cc_num, :cc_exp)
  end

  def find_order
    @order = Order.find_by(id: params[:id])
  end

end
