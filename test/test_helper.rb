ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require "minitest/rails"
require "minitest/reporters"  # for Colorized output
#  For colorful output!
Minitest::Reporters.use!(
  Minitest::Reporters::SpecReporter.new,
  ENV,
  Minitest.backtrace_filter
)

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  # parallelize(workers: :number_of_processors) # causes out of order output.

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  def perform_login(merchant = nil)
  #   merchant ||= Merchant.first

  #   login_data = {
  #     merchant: {
  #       name: "Harry Potter",
  #       uid: "123456",
  #       provider: "github",
  #       email: "harrypotter@hogwarts.com"
  #     },
  #   }
  #   post github_login_path, params: login_data

  #   # Verify the user ID was saved - if that didn't work, this test is invalid
  #   binding.pry
  #   expect(session[:merchant_id]).must_equal merchant.id

  #   return merchant
  end

  def populate_cart
    # Go to products_path to get a return_to session key
    get products_path

    # Look for product to add to cart
    @product = products(:lion)
    patch add_to_cart_path(@product.id)
  end
end
