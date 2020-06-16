class ReviewsController < ApplicationController
  def new
    @product = Product.find_by(id: params[:product_id])
    @review = Review.new
  end

  def create
    @review = Review.new(review_params)
    @product = Product.find_by(id: review_params[:product_id])

    if @product.nil?
      flash[:error] = "We couldn't find that product in our database"
      redirect_to products_path
      return
    end

    if session[:merchant_id] == @product.merchant.id
      flash[:warning] = "Boooo!!! We at regrEtsy pride ourselves in our unbiased reviews. You ought to be ashamed of trying to review your own product! >:("
      redirect_to product_path(@product.id)
      return
    end

    if @review.save
      redirect_to product_path(@review.product.id)
      flash[:success] = "Thanks for leaving a review for #{@review.product.name}"
      return
    else
      # TODO - figure out a way to do it with render and bad request instead
      redirect_to new_product_review_path(review_params[:product_id])
      flash[:warning] = "Must enter a rating to create a review"
      # render :new_product_review_path(review_params[:product_id]), status: :bad_request
      return
    end
  end

  private

  def review_params
    return params.require(:review).permit(:rating, :review_text, :product_id)
  end
end
