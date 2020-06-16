require "test_helper"

describe HomepagesController do
  #   describe "root" do
  #     describe "root without login (guest)" do
  #       it "must get home if there are enough products and merchants" do
  #         get root_path
  #         must_respond_with :success
  #       end

  #       it "must get home if there are no merchants or products" do
  #         Review.destroy_all
  #         Product.destroy_all
  #         Merchant.destroy_all

  #         get root_path
  #         must_respond_with :success
  #       end
  #     end

  describe "root without login (guest)" do
    before do
      perform_login
    end
  end
end

#       it "must get home if there are enough products and merchants" do
#         get root_path
#         must_respond_with :success
#       end

#       it "must get home if there are no merchants or products" do
#         Review.destroy_all
#         Product.destroy_all
#         Merchant.destroy_all

#         get root_path
#         must_respond_with :success
#       end
#     end
#   end
# end
