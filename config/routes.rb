Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  get "/payment-momo", to: "payments#momo"
  post "/payment-paypal", to: "payments#paypal"
  get "/payment-paypal", to: "payments#paypal_template"

  get "/", to: "payments#index"
  get "/success", to: "payments#success"
end
