class HomepagesController < ApplicationController

  def root
    @featured_products = Product.featured_products
    @featured_merchants = Merchant.featured_merchants
  end

  def careers
  end

  def contact
  end

  def investors
  end

  def impact
  end
  
end
