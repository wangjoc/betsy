require "simplecov"
SimpleCov.start

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
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
  # parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  def setup
    OmniAuth.config.test_mode = true
  end

  def mock_auth_hash(merchant)
    return {
             provider: merchant.provider,
             uid: merchant.uid,
             info: {
               nickname: merchant.name,
               email: merchant.email,
               image: merchant.avatar,
             },
           }
  end

  def perform_login(merchant = nil)
    merchant ||= Merchant.first

    OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(merchant))

    get omniauth_callback_path(:github)
    merchant = Merchant.find_by(uid: merchant.uid, name: merchant.name)

    expect(merchant).wont_be_nil
    expect(session[:merchant_id]).must_equal merchant.id
    return merchant
  end

  def populate_cart
    # Go to products_path to get a return_to session key
    get products_path

    # Look for product to add to cart
    @product = products(:lion)
    patch add_to_cart_path(@product.id)
  end
end
