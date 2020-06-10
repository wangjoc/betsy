Rails.application.routes.draw do
  root to: 'homepages#root'
  
  # # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  resources :products
  resources :orders

  get "/orders/:id/purchase", to: "orders#purchase", as: "purchase"
  patch "/orders/:id/complete", to: "orders#complete", as: "complete"
end
