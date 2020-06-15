require "test_helper"

describe MerchantsController do
  # describe "show" do
  #   before do 
  #     @merchant_faker = merchants(:faker)
  #   end

  #   describe "show without login (guest)" do
  #     it "can get the show page for valid merchant" do
  #       get merchant_path(@merchant_faker.id)

  #       must_respond_with :success
  #     end

  #     it "redirect show if invalid merchant" do
  #       get merchant_path(-1)

  #       must_respond_with :redirect
  #       must_redirect_to products_path
  #     end
  #   end

  #   describe "show with login as merchant" do
  #     before do 
  #       perform_login
  #     end

  #     it "can get the show page for valid merchant" do
  #       get merchant_path(@merchant_faker.id)

  #       must_respond_with :success
  #     end

  #     it "redirect show if invalid merchant" do
  #       get merchant_path(-1)

  #       must_respond_with :redirect
  #       must_redirect_to products_path
  #     end
  #   end
  # end

  describe 'create/login' do
    it 'can login an existing user' do
      merchant = perform_login(merchants(:faker))

      must_respond_with :redirect
      must_redirect_to root_path
      expect(session[:merchant_id]).must_equal merchants(:faker).id
    end

    it 'can login a new user' do
      new_merchant = Merchant.new(
                      name: 'rycall', 
                      provider: 'github', 
                      uid: 123456789,
                      email: 'rycall@steam.com',
                      avatar: 'https://imgur.com/Q6snmV7.jpg'
                    )

      expect {
        logged_in_user = perform_login(new_merchant)
      }.must_change "Merchant.count", 1
      
      must_respond_with :redirect
      must_redirect_to root_path
      expect(session[:merchant_id]).must_equal Merchant.last.id
    end

    # # TODO - not sure if this is something we can test, might have more to do with the gem itself
    # # TODO - this might not be necessary because I think OAuth will just switch to the new user, Leah thoughts?
    # it 'cannot login a user if another is already logged in' do
    #   perform_login(merchants(:faker))
    #   perform_login(merchants(:greentye))

    #   expect(session[:merchant_id]).must_equal merchants(:faker).id
    #   must_respond_with :redirect
    #   must_redirect_to root_path
    #   # expect(session[:merchant_id]).must_equal merchants(:greentye).id
    # end
  end

  describe "logout" do
    it 'can log out an existing user' do
      perform_login
      expect(session[:merchant_id]).wont_be_nil

      post logout_path
      expect(session[:merchant_id]).must_be_nil

      must_redirect_to root_path
    end

    it 'redirects to root path if a guest/non-logged in user tries to logout' do
      post logout_path, params: {}
      must_redirect_to root_path
    end
  end

  describe "dashboard" do 
    it "can get the dashboard page if logged in" do 
      merchant = merchants(:faker)
      perform_login(merchant)
      get dashboard_path

      must_respond_with :success
    end

    it "can't get to the dashboard page if not logged in" do 
      get dashboard_path 

      must_respond_with :redirect
      must_redirect_to root_path
    end
  end

  # describe "confirmation" do 
  #   it "can get to a confirmation page" do 
  #     merchant = merchants(:hannah)
  #     op = OrderProduct.first
  #     perform_login(merchant)
      
  #     get merchant_confirmation_path(op.order_id)
  #     must_respond_with :success
  #   end

  #   it "should not get into a confirmation page if not logged in" do 
      
  # end











end
