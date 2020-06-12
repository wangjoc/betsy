Rails.application.routes.draw do
  root to: 'homepages#root'
  
  # # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  get "/merchants/dashboard", to: "merchants#dashboard", as: "dashboard"
  get "/orders/receipt", to: "orders#receipt", as: "receipt"
  # get "/products/:id/review_product", to: "products#review_product", as: "review_product"
  get "/reviews/:id/review_product", to: "reviews#review_product", as: "review_product"

  resources :categories, only: [:index, :show, :new, :create]
  resources :reviews, only: [:new, :create]
  resources :orders, except: [:index]
  resources :merchants

  resources :products do
    resources :categories
    resources :reviews
  end

  patch "/orders/:id/purchase", to: "orders#purchase", as: "purchase"
  patch "/orders/:id/cancel", to: "orders#cancel", as: "cancel"
  patch "/orders/:id/complete", to: "orders#complete", as: "complete"

  patch "/products/:id/add_to_cart", to: "products#add_to_cart", as: "add_to_cart"
  patch "/products/:id/remove_from_cart", to: "products#remove_from_cart", as: "remove_from_cart"


  get "/auth/github", as: "github_login"
  get "/auth/:provider/callback", to: "merchants#create", as: "omniauth_callback"
  post "/logout", to: "merchants#logout", as: "logout"

  get "/merchants/current", to: "merchants#current", as: "current_merchant"

end
