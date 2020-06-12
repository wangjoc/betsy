class ReviewsController < ApplicationController

  def new 
    @review = Review.new
  end

  def review_product
    @product = Product.find_by(id: params[:id])
    @review = Review.new
  end

  def create
    @review = Review.new(review_params) 

    if @review.save 
      redirect_to product_path(@review.product.id)
      flash[:success] = "Successfully created new review"
      return
    else 
      render :new, status: :bad_request
      return
    end
  end

  private

  def review_params
    return params.require(:review).permit(:rating, :review_text, :product_id)
  end
end
