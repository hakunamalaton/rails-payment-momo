Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  get "/payment-momo", to: "payments#momo"
  get "/payment-momo-status", to: "payments#check_transaction_status_momo"
  get "/payment-momo-refund", to: "payments#refund_momo"
  get "/payment-momo-confirm", to: "payments#confirm_payment"
  
  post "/payment-paypal", to: "payments#paypal"
  #get "/payment-paypal", to: "payments#paypal_template"

  get "/", to: "payments#index"
  get "/success", to: "payments#success"
end 
