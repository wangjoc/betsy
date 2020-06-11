Rails.application.routes.draw do
  root to: 'homepages#root'
  
  # # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  resources :products do
    resources :categories
    resources :reviews
  end

  resources :orders
  resources :merchants

  get "/orders/:id/purchase", to: "orders#purchase", as: "purchase"
  patch "/orders/:id/complete", to: "orders#complete", as: "complete"

  get "/auth/github", as: "github_login"
  get "/auth/:provider/callback", to: "merchants#create"

  post "/logout", to: "merchants#logout", as: "logout"
  get "/merchants/current", to: "merchants#current", as: "current_merchant"
  get "/merchants/dashboard", to: "merchants#dashboard", as: "dashboard"
end
