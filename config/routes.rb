Rails.application.routes.draw do
  root to: "homepages#root"

  get "/merchants/dashboard", to: "merchants#dashboard", as: "dashboard"
  get "/orders/receipt", to: "orders#receipt", as: "receipt"
  get "/orders/confirm", to: "orders#confirm", as: "confirm"
  patch "/orders/purchase", to: "orders#purchase", as: "purchase"

  resources :categories, only: [:show, :new, :create]
  # I thiiiink we don't need these anymore (Leah added @product to the model of the partial so it's working okay now)
  #resources :reviews, only: [:new, :create]
  resources :orders, except: [:index]
  resources :merchants, only: [:show, :create]

  resources :products do
    resources :categories
    resources :reviews, only: [:new, :create]
  end

  patch "/orders/:id/ship", to: "orders#ship", as: "ship"
  patch "/orders/:id/cancel", to: "orders#cancel", as: "cancel"
  patch "/orders/:id/complete", to: "orders#complete", as: "complete"

  patch "/products/:id/add_to_cart", to: "products#add_to_cart", as: "add_to_cart"
  patch "/products/:id/remove_from_cart", to: "products#remove_from_cart", as: "remove_from_cart"
  patch "/products/:id/delete_from_cart", to: "products#delete_from_cart", as: "delete_from_cart"

  get "/auth/github", as: "github_login"
  get "/auth/:provider/callback", to: "merchants#create", as: "omniauth_callback"
  post "/logout", to: "merchants#logout", as: "logout"
end
