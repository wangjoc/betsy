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
end