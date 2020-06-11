module ApplicationHelper
  def cart_num_items
    count = 0

    session[:shopping_cart].each do |key, value|
      count += value
    end

    return count
  end
end
