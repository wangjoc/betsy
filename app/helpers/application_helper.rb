module ApplicationHelper

  def render_rating(rating)
    
    rating = rating.to_i

    filled_star = '<i class="fas fa-star"></i>'
    empty_star = '<i class="far fa-star"></i>'
    
    # make a list of all the filled stars
    star_list = []
    until rating == 0
      star_list << filled_star
      rating -= 1
    end
    
    # fill out the rest of the list with empty stars
    until star_list.length == 5
      star_list << empty_star
    end
    
    # convert star list to string
    stars = star_list.join("")
    
    return (
      stars.html_safe
    )
  end

  

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
