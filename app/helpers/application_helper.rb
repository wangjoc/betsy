module ApplicationHelper
  def cart_num_items
    count = 0

    if !session[:shopping_cart].nil?
      session[:shopping_cart].each do |key, value|
        count += value
      end
    end

    return count
  end
end
