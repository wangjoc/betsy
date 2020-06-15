class CategoriesController < ApplicationController
  before_action :require_login, only: [:new, :create]

  def show
    @category = Category.find_by(id: params[:id])

    if @category.nil?
      flash[:warning] = "Category does not exist, please select another"
      redirect_to products_path
      return
    end

    @products = Product.by_category(@category.id)
    session[:return_to] = category_path(@category.id)
  end  

  def create
    @category = Category.new(category_params)

    if @category.save
      redirect_to dashboard_path
      flash[:success] = "Successfully created category: #{@category.category}"
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
