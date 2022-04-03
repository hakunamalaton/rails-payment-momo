class Paypal::CheckoutsController < ApplicationController
  
  include PayPal::SDK::REST
  def index
    payment = Payment.new({
      intent: "sale",
      payer: {
        payment_method: "paypal"
      },
      redirect_urls: {
        return_url: "http://localhost:3000",
        cancel_url: "http://localhost:3000"
      },
      transactions: [
        {
          amount: {
            total: 50000,
            currency: "USD"
          },
          description: "Testing paypal payment"
        }
      ]
    })

    if payment.create
      redirect_url = payment.links.find do |v|
        v.rel == "approval_url"
      end.href

      redirect_to redirect_url
    else
      redirect_to "/", alert: "Somethings wrong!"
    end
  end
end