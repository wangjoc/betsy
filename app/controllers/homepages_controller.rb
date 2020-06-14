class HomepagesController < ApplicationController
  def root
    @featured_products = Product.featured_products
    @featured_merchants = Merchant.featured_merchants
  end
end
