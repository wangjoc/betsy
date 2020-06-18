Rails.application.routes.draw do
  root to: "homepages#root"

  # Merchant dashboard
  get "/merchants/dashboard", to: "merchants#dashboard", as: "dashboard"

  # Purchase confirmation/receipt
  get "/orders/receipt", to: "orders#receipt", as: "receipt"
  get "/orders/confirm", to: "orders#confirm", as: "confirm"
  patch "/orders/purchase", to: "orders#purchase", as: "purchase"

  # Merchant order management
  patch "/orders/:id/ship", to: "orders#ship", as: "ship"
  patch "/orders/:id/cancel", to: "orders#cancel", as: "cancel"
  patch "/orders/:id/complete", to: "orders#complete", as: "complete"

  # Custom cart routes
  patch "/products/:id/add_to_cart", to: "products#add_to_cart", as: "add_to_cart"
  patch "/products/:id/remove_from_cart", to: "products#remove_from_cart", as: "remove_from_cart"
  patch "/products/:id/delete_from_cart", to: "products#delete_from_cart", as: "delete_from_cart"

  # Custom product routes
  patch "/products/:id/retire", to: "products#retire", as: "retire"
  get "products/search", to: "products#search", as: "search"

  # Github authorization
  get "/auth/github", as: "github_login"
  get "/auth/:provider/callback", to: "merchants#create", as: "omniauth_callback"
  post "/logout", to: "merchants#logout", as: "logout"

  #RESTful Routes
  resources :categories, only: [:show, :new, :create]
  resources :orders, except: [:index]
  resources :merchants, only: [:show, :create]

  resources :products do
    resources :categories
    resources :reviews, only: [:new, :create]
  end
end
