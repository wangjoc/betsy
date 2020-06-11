class CategoriesController < ApplicationController
  def index
    @products_by_category = Product.categorize_by_category
    session[:return_to] = categories_path
  end

  def show  
    @category = Category.find_by(id: params[:id])
    @products = Product.by_category(@category.id)
    session[:return_to] = category_path(@category.id)
  end

  def new
    @category = Category.new
  end

  def create
    @category = Category.new(category_params) 

    if @category.save 
      redirect_to dashboard_path
      # flash[:success] = "Successfully created new category"
      return
    else 
      render :new, status: :bad_request
      return
    end
  end

  private

  def category_params
    return params.require(:category).permit(:category)
  end

end
