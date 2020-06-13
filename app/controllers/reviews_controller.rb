class ReviewsController < ApplicationController

  def index
    @review = Review.where(product_id: params[:product_id])
  end

  def new 
    @product = Product.find_by(id: params[:product_id])
    @review = Review.new
  end

  def create
    @review = Review.new(review_params) 

    if @review.save 
      redirect_to product_path(@review.product.id)
      flash[:success] = "Successfully created new review"
      return
    else 
      # TODO - figure out a way to do it with render and bad request instead
      redirect_to new_product_review_path(review_params[:product_id])
      flash[:warning] = "Successfully created new review"
      # render :new_product_review_path(review_params[:product_id]), status: :bad_request
      return
    end
  end

  private

  def review_params
    return params.require(:review).permit(:rating, :review_text, :product_id)
  end
end
