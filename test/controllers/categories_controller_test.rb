require "test_helper"

describe CategoriesController do
  describe 'new' do 
    describe "new without login (guest)" do
      it "cannot create new category if not signed in" do
        get new_category_path

        must_respond_with :redirect
      end
    end

    describe "new with login as merchant" do
      before do
        perform_login
      end

      it "create new category if signed in" do
        get new_category_path

        must_respond_with :success
      end
    end
  end

  describe "create" do
    let (:new_category) {
      {
        category: {
          category: "Weapons"
        }
      }
    }

    describe "create without login (guest)" do
      it "cannot create new category if not signed in" do
        expect {
          post categories_path, params: new_category
        }.must_differ 'Category.count', 0

        must_respond_with :redirect
        must_redirect_to root_path
      end
    end

    describe "create with login as merchant" do
      before do
        perform_login
      end

      it "create new category if signed in" do
        expect {
          post categories_path, params: new_category
        }.must_differ 'Category.count', 1

        must_respond_with :redirect
        must_redirect_to dashboard_path
      end

      it "cannot create new category if missing category name" do
        new_category[:category][:category] = nil
        
        expect {
          post categories_path, params: new_category
        }.must_differ 'Category.count', 0
        
        must_respond_with :bad_request
      end
    end
  end
end
