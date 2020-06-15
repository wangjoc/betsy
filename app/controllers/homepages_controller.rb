class HomepagesController < ApplicationController
  def root
    @featured_products = Product.featured_products
    @featured_merchants = Merchant.featured_merchants
    @newest_merchants = Merchant.newest_merchants
  end
end
