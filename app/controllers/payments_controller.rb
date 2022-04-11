require 'net/https'
require 'uri'
require 'json'
require 'openssl'
# require 'Base64'
require 'securerandom'
require 'paypal-sdk-rest'

class PaymentsController < ApplicationController
  protect_from_forgery with: :null_session

  include PayPal::SDK::REST
  
  def index 

  end

  def paypal
    redirect_url = ""

    @payment = Payment.new({
      :intent =>  "sale",
      :payer =>  {
        :payment_method =>  "paypal" },
      :redirect_urls => {
        :return_url => "http://localhost:3000/success",
        :cancel_url => "http://localhost:3000/" },
      :transactions =>  [{
        :item_list => {
          :items => [{
            :name => "item",
            :sku => "item",
            :price => "5",
            :currency => "USD",
            :quantity => 1 }]},
        :amount =>  {
          :total =>  "5",
          :currency =>  "USD" },
        :description =>  "This is the payment transaction description." }]})
    
    if @payment.create
      redirect_url = @payment.links.find do |v|
        v.rel == "approval_url"
      end.href
    end
    redirect_to redirect_url, allow_other_host: true
  end

  # def paypal_template
  #   paypal
  #   redirect_to @redirect_url, allow_other_host: true
  # end

  def momo
  #parameters send to MoMo get get payUrl
    endpoint = "https://test-payment.momo.vn/v2/gateway/api/create";
    partnerCode = Rails.application.credentials.config.dig(:momo, :partner_code)
    accessKey = Rails.application.credentials.config.dig(:momo, :access_key)
    secretKey = Rails.application.credentials.config.dig(:momo, :secret_key)
    orderInfo = "pay with MoMo"
    redirectUrl = "https://webhook.site/b3088a6a-2d17-4f8d-a383-71389a6c600b"
    ipnUrl = "https://webhook.site/b3088a6a-2d17-4f8d-a383-71389a6c600b"
    amount = params[:amount]
    orderId = SecureRandom.uuid
    requestId = SecureRandom.uuid
    requestType = "captureWallet"
    extraData = "" #pass empty value or Encode base64 JsonString

    #before sign HMAC SHA256 with format: accessKey=$accessKey&amount=$amount&extraData=$extraData&ipnUrl=$ipnUrl&orderId=$orderId&orderInfo=$orderInfo&partnerCode=$partnerCode&redirectUrl=$redirectUrl&requestId=$requestId&requestType=$requestType
    rawSignature = "accessKey="+accessKey+"&amount="+params[:amount]+"&extraData="+extraData+"&ipnUrl="+ipnUrl+"&orderId="+orderId+"&orderInfo="+orderInfo+"&partnerCode="+partnerCode+"&redirectUrl="+redirectUrl+"&requestId="+requestId+"&requestType="+requestType
    #puts raw signature
    puts "--------------------RAW SIGNATURE----------------"
    puts rawSignature
    #signature
    signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), secretKey, rawSignature)
    puts "--------------------SIGNATURE----------------"
    puts signature

    #json object send to MoMo endpoint
    jsonRequestToMomo = {
                    :partnerCode => partnerCode,
                    :partnerName => "Test",
                    :storeId => "MomoTestStore",
                    :requestId => requestId,
                    :amount => amount,
                    :orderId => orderId,
                    :orderInfo => orderInfo,
                    :redirectUrl => redirectUrl,
                    :ipnUrl => ipnUrl,
                    :lang => "vi",
                    :extraData => extraData,
                    :requestType => requestType,
                    :signature => signature,
                }
    puts "--------------------JSON REQUEST----------------"
    puts JSON.pretty_generate(jsonRequestToMomo)
    # Create the HTTP objects
    uri = URI.parse(endpoint)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Post.new(uri.path)
    request.add_field('Content-Type', 'application/json')
    request.body = jsonRequestToMomo.to_json
    puts request

    # Send the request and get the response
    puts "SENDING...."
    response = http.request(request)
    result = JSON.parse(response.body)
    puts "--------------------RESPONSE----------------" 
    puts JSON.pretty_generate(result)
    puts "pay URL is: " + result["payUrl"]
    redirect_to result["payUrl"], allow_other_host: true
  end


  def check_transaction_status_momo
    #parameters send to MoMo get get payUrl
    endpoint = "https://test-payment.momo.vn/v2/gateway/api/query";
    partnerCode = Rails.application.credentials.config.dig(:momo, :partner_code)
    requestId = SecureRandom.uuid
    orderId = SecureRandom.uuid
    accessKey = Rails.application.credentials.config.dig(:momo, :access_key)
    secretKey = Rails.application.credentials.config.dig(:momo, :secret_key)
    lang = "vi"


    rawSignature = "accessKey="+accessKey+"&orderId="+orderId+"&partnerCode="+partnerCode+"&requestId="+requestId
    #puts raw signature
    puts "--------------------RAW SIGNATURE----------------"
    puts rawSignature
    #signature
    signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), secretKey, rawSignature)
    puts "--------------------SIGNATURE----------------"
    puts signature

    jsonRequestToMomo = {
      :partnerCode => partnerCode,
      :requestId => requestId,
      :orderId => orderId,
      :lang => "vi",
      :signature => signature,
  }
    #accessKey = Rails.application.credentials.config.dig(:momo, :access_key)
    #secretKey = Rails.application.credentials.config.dig(:momo, :secret_key)
    # orderInfo = "pay with MoMo"
    # redirectUrl = "https://webhook.site/b3088a6a-2d17-4f8d-a383-71389a6c600b"
    # ipnUrl = "https://webhook.site/b3088a6a-2d17-4f8d-a383-71389a6c600b"
    # amount = "100000"
    # requestType = "captureWallet"
    # extraData = "" #pass empty value or Encode base64 JsonString

    # #before sign HMAC SHA256 with format: accessKey=$accessKey&amount=$amount&extraData=$extraData&ipnUrl=$ipnUrl&orderId=$orderId&orderInfo=$orderInfo&partnerCode=$partnerCode&redirectUrl=$redirectUrl&requestId=$requestId&requestType=$requestType
    # rawSignature = "accessKey="+accessKey+"&amount="+amount+"&extraData="+extraData+"&ipnUrl="+ipnUrl+"&orderId="+orderId+"&orderInfo="+orderInfo+"&partnerCode="+partnerCode+"&redirectUrl="+redirectUrl+"&requestId="+requestId+"&requestType="+requestType
    # #puts raw signature
    # puts "--------------------RAW SIGNATURE----------------"
    # puts rawSignature
    # #signature
    # signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), secretKey, rawSignature)
    # puts "--------------------SIGNATURE----------------"
    # puts signature

    #json object send to MoMo endpoint
    
    puts "--------------------JSON REQUEST----------------"
    puts JSON.pretty_generate(jsonRequestToMomo)
    # Create the HTTP objects
    uri = URI.parse(endpoint)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Post.new(uri.path)
    request.add_field('Content-Type', 'application/json')
    request.body = jsonRequestToMomo.to_json
    puts request

    # Send the request and get the response
    puts "SENDING...."
    response = http.request(request)
    result = JSON.parse(response.body)
    puts "--------------------RESPONSE----------------" 
    render json: JSON.pretty_generate(result)
    # puts "pay URL is: " + result["payUrl"]
    # redirect_to result["payUrl"], allow_other_host: true
  end

  def refund_momo
    #parameters send to MoMo get get payUrl
    endpoint = "https://test-payment.momo.vn/v2/gateway/api/refund";
    partnerCode = Rails.application.credentials.config.dig(:momo, :partner_code)
    requestId = SecureRandom.uuid
    orderId = "d2e98606-81ba-466d-9b03-ddfa486e531f"
    amount = params[:amount]
    transId = "144492817"
    description = "hi"
    accessKey = Rails.application.credentials.config.dig(:momo, :access_key)
    secretKey = Rails.application.credentials.config.dig(:momo, :secret_key)


    rawSignature = "accessKey="+accessKey+"&orderId="+orderId+"&partnerCode="+partnerCode+"&amount="+amount+"&transId="+transId+"&requestId="+requestId+"&description="+description
    #puts raw signature
    puts "--------------------RAW SIGNATURE----------------"
    puts rawSignature
    #signature
    signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), secretKey, rawSignature)
    puts "--------------------SIGNATURE----------------"
    puts signature

    jsonRequestToMomo = {
      :partnerCode => partnerCode,
      :requestId => requestId,
      :amount => amount,
      :orderId => orderId,
      :transId => transId,
      :description => description,
      :lang => "vi",
      :signature => signature,
  }
    
    puts "--------------------JSON REQUEST----------------"
    puts JSON.pretty_generate(jsonRequestToMomo)
    # Create the HTTP objects
    uri = URI.parse(endpoint)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Post.new(uri.path)
    request.add_field('Content-Type', 'application/json')
    request.body = jsonRequestToMomo.to_json
    puts request

    # Send the request and get the response
    puts "SENDING...."
    response = http.request(request)
    result = JSON.parse(response.body)
    puts "--------------------RESPONSE----------------" 
    render json: JSON.pretty_generate(result)
    # puts "pay URL is: " + result["payUrl"]
    # redirect_to result["payUrl"], allow_other_host: true
  end

  def confirm_payment
    #parameters send to MoMo get get payUrl
    endpoint = "https://test-payment.momo.vn/v2/gateway/api/confirm";
    partnerCode = Rails.application.credentials.config.dig(:momo, :partner_code)
    requestId = SecureRandom.uuid
    orderId = SecureRandom.uuid
    requestType = "cancel"
    amount = params[:amount]
    description = "hi"
    accessKey = Rails.application.credentials.config.dig(:momo, :access_key)
    secretKey = Rails.application.credentials.config.dig(:momo, :secret_key)
    lang = "vi"


    rawSignature = "accessKey="+accessKey+"&amount="+amount+"&description="+description+ \
    "&orderId="+orderId+"&partnerCode="+partnerCode+"&requestId="+requestId \
    +"&requestType="+requestType
    #puts raw signature
    puts "--------------------RAW SIGNATURE----------------"
    puts rawSignature
    #signature
    signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), secretKey, rawSignature)
    puts "--------------------SIGNATURE----------------"
    puts signature

    jsonRequestToMomo = {
      :partnerCode => partnerCode,
      :requestId => requestId,
      :orderId => orderId,
      :requestType => requestType,
      :amount => amount,
      :lang => "vi",
      :signature => signature,
  }

    
    puts "--------------------JSON REQUEST----------------"
    puts JSON.pretty_generate(jsonRequestToMomo)
    # Create the HTTP objects
    uri = URI.parse(endpoint)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Post.new(uri.path)
    request.add_field('Content-Type', 'application/json')
    request.body = jsonRequestToMomo.to_json
    puts request

    # Send the request and get the response
    puts "SENDING...."
    response = http.request(request)
    result = JSON.parse(response.body)
    puts "--------------------RESPONSE----------------" 
    render json: JSON.pretty_generate(result)
    # puts "pay URL is: " + result["payUrl"]
    # redirect_to result["payUrl"], allow_other_host: true
  end

end
