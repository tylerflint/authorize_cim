require 'crack'
require 'builder'
require 'uri'
require 'net/http'
require 'net/https'

class InvalidOrMissingCredentials < Exception 
end

class AuthorizeCim
  
  def initialize(attrs)
    
    raise InvalidOrMissingCredentials unless attrs[:key] && attrs[:login]
    
    @key   = attrs[:key]
    @login = attrs[:login]
    
    @endpoint = case attrs[:endpoint]
      when :live then 'https://api.authorize.net/xml/v1/request.api'
      when :test then 'https://apitest.authorize.net/xml/v1/request.api'
      else 'https://api.authorize.net/xml/v1/request.api'
    end
    @uri = URI.parse(@endpoint)
    
      
  end

  # Create a new customer profile
  #
  #
  # perams:
  #   Necessary:
  #     :merchant_id => '<some id>'  (up to 20 characters)
  #    or
  #     :description => '<some discription>' (up to 255 characters)
  #    or
  #     :email => '<emailaddress>' (up to 255 characters)
  #  
  # return: 
  #  xml return converted to hash containing the return_code and customer_profile_id
  #     note: a return code of I00001 is good, anything else is bad
  #
  def create_customer_profile(input)
  	data = build_request('createCustomerProfileRequest') do |xml|
      xml.tag!('profile') do
        xml.merchantCustomerId input[:merchant_id] if input[:merchant_id]
        xml.description input[:description] if input[:description]
        xml.email input[:email] if input[:email]
      end
    end
    parse send(data)
  end
  	
  # Create a new customer payment profile for an existing customer profile. 
  # You can create up to 10 payment profiles for each customer profile.
  # 
  # perams:
  #     A hash containing all necessary fields
  #   all possible perams:
  #     :ref_id               => '<id>' (up to 20 digits (optional))
  #     :customer_profile_id  => <id of customer> (numeric (necessary))
  #     :payment_profile      => {
  #       :bill_to => {  (optional)
  #         :first_name     => '<billing first name>' (up to 50 characters (optional))
  #         :last_name      => '<billing last name>' (up to 50 characters (optional))
  #         :company        => '<company name>' (up to 50 characters (optional))
  #         :address        => '<address>' (up to 60 characters (optional))
  #         :city           => '<city>' (up to 40 characters (optional))
  #         :state          => '<state>' (valid 2 character state code (optional))
  #         :zip            => '<zip code>' (up to 20 characters (optional))
  #         :country        => '<country>' (up to 60 characters (optional))
  #         :phone_number   => '<phone number>' (up to 25 digits (optional))
  #         :fax_number     => '<fax number>' (up to 25 digits (optional))
  #       }
  #       :payment => { (NECESSARY > must include either bank info or credit card info)
  #         :credit_card => { (necessary if there is no bank_account in payment hash)
  #           :card_number      => <number> (13 to 16 digits (necessary))
  #           :expiration_date  => '<YYYY-MM>' (has to be 4 digit year, dash line, then 2 digit month (necessary))
  #           :card_code        => <number> (3 or 4 digit number on back of card (optional))
  #         }
  #         :bank_account => { (necessary if there is no credit_card in payment hash)
  #           :account_type     => '<type of account>' (must be "checking", "savings", or "businessChecking" (necessary))
  #           :routing_number   => <number> (9 digit bank routing number (necessary))
  #           :account_number   => <number> (5 to 17 digit number (necessary))
  #           :name_on_account  => '<name>' (up to 22 characters (necessary))
  #           :echeck_type      => '<type>' (needs to be 'CCD', 'PPD', 'TEL', or 'WEB' (optional))
  #           :bank_name        => '<bank name>' (up to 50 characters (optional))
  #         }
  #         
  #       }
  #     }
  #     :validation_mode => '<mode>' (needs to be 'none', 'testMode', 'liveMode', or 'oldLiveMode' (necessary))
  # 
  # returns:
  #   xml converted to hash table for easy access
  # 
  def create_customer_payment_profile(input)
  	data = build_request('createCustomerPaymentProfileRequest') do |xml|
  	  xml.refId input[:ref_id] if input[:ref_id]
      xml.customerProfileId input[:customer_profile_id] if input[:customer_profile_id]
      xml.tag!('paymentProfile') do
        if input[:payment_profile][:bill_to]
          xml.tag!('billTo') do
            xml.firstName input[:payment_profile][:bill_to][:first_name] if input[:payment_profile][:bill_to][:first_name]
            xml.lastName input[:payment_profile][:bill_to][:last_name] if input[:payment_profile][:bill_to][:last_name]
            xml.company input[:payment_profile][:bill_to][:company] if input[:payment_profile][:bill_to][:company]
            xml.address input[:payment_profile][:bill_to][:address] if input[:payment_profile][:bill_to][:address]
            xml.city input[:payment_profile][:bill_to][:city] if input[:payment_profile][:bill_to][:city]
            xml.state input[:payment_profile][:bill_to][:state] if input[:payment_profile][:bill_to][:state]
            xml.zip input[:payment_profile][:bill_to][:zip] if input[:payment_profile][:bill_to][:zip]
            xml.country input[:payment_profile][:bill_to][:country] if input[:payment_profile][:bill_to][:country]
            xml.phoneNumber input[:payment_profile][:bill_to][:phone_number] if input[:payment_profile][:bill_to][:phone_number]
            xml.faxNumber input[:payment_profile][:bill_to][:fax_number] if input[:payment_profile][:bill_to][:fax_number]
          end
        end
        xml.tag!('payment') do
          if input[:payment_profile][:payment][:credit_card]
            xml.tag!('creditCard') do
              xml.cardNumber input[:payment_profile][:payment][:credit_card][:card_number] if input[:payment_profile][:payment][:credit_card][:card_number]
              xml.expirationDate input[:payment_profile][:payment][:credit_card][:expiration_date] if input[:payment_profile][:payment][:credit_card][:expiration_date]
              xml.cardCode input[:payment_profile][:payment][:credit_card][:card_code] if input[:payment_profile][:payment][:credit_card][:card_code]
            end
          elsif input[:payment_profile][:payment][:bank_account]
            xml.tag!('bankAccount') do
              xml.accountType input[:payment_profile][:payment][:bank_account][:account_type] if input[:payment_profile][:payment][:bank_account][:account_type]
              xml.routingNumber input[:payment_profile][:payment][:bank_account][:routing_number] if input[:payment_profile][:payment][:bank_account][:routing_number]
              xml.accountNumber input[:payment_profile][:payment][:bank_account][:account_number] if input[:payment_profile][:payment][:bank_account][:account_number]
              xml.nameOnAccount input[:payment_profile][:payment][:bank_account][:name_on_account] if input[:payment_profile][:payment][:bank_account][:name_on_account]
              xml.echeckType input[:payment_profile][:payment][:bank_account][:echeck_type] if input[:payment_profile][:payment][:bank_account][:echeck_type]
              xml.bankName input[:payment_profile][:payment][:bank_account][:bank_name] if input[:payment_profile][:payment][:bank_account][:bank_name]
            end
          end
        end
        xml.validationMode input[:payment_profile][:validation_mode] if input[:payment_profile][:validation_mode]
      end
    end
    parse send(data)
  end
  
  # Create a new customer shipping address for an existing customer profile. 
  # You can create up to 100 customer shipping addresses for each customer profile.
  # 
  # perams:
  #     A hash containing all necessary fields
  #   all possible perams:
  #     :ref_id               => '<id>' (up to 20 digits (optional))
  #     :customer_profile_id  => <id of customer> (numeric (necessary))
  #     :address => {  (a hash containing address information(necessary)
  #       :first_name     => '<billing first name>' (up to 50 characters (optional))
  #       :last_name      => '<billing last name>' (up to 50 characters (optional))
  #       :company        => '<company name>' (up to 50 characters (optional))
  #       :address        => '<address>' (up to 60 characters (optional))
  #       :city           => '<city>' (up to 40 characters (optional))
  #       :state          => '<state>' (valid 2 character state code (optional))
  #       :zip            => '<zip code>' (up to 20 characters (optional))
  #       :country        => '<country>' (up to 60 characters (optional))
  #       :phone_number   => '<phone number>' (up to 25 digits (optional))
  #       :fax_number     => '<fax number>' (up to 25 digits (optional))
  #     }
  #
  # returns:
  #   xml converted to hash table for easy access
  def create_customer_shipping_address(input)
  	data = build_request('createCustomerShippingAddressRequest') do |xml|
  	  xml.refId input[:ref_id] if input[:ref_id]
      xml.customerProfileId input[:customer_profile_id] if input[:customer_profile_id]
      xml.tag!('address') do
        xml.firstName input[:address][:first_name] if input[:address][:first_name]
        xml.lastName input[:address][:last_name] if input[:address][:last_name]
        xml.company input[:address][:company] if input[:address][:company]
        xml.address input[:address][:address] if input[:address][:address]
        xml.city input[:address][:city] if input[:address][:city]
        xml.state input[:address][:state] if input[:address][:state]
        xml.zip input[:address][:zip] if input[:address][:zip]
        xml.country input[:address][:country] if input[:address][:country]
        xml.phoneNumber input[:address][:phone_number] if input[:address][:phone_number]
        xml.faxNumber input[:address][:fax_number] if input[:address][:fax_number]
      end
    end
    parse send(data)
  end
  
  # Create a new payment transaction from an existing customer profile.
  #
  # perams:
  #     A hash containing all necessary fields
  #   all possible perams:
  #     :ref_id      => '<id>' (up to 20 digits (optional))
  #     :transaction => { (REQUIRED)                                                          TODO \/ I dont know the rest...
  #     :trans_type => '<transType>' (must be profileTransAuthCapture, profileTransAuthOnly, profileTransPriorAuthCapture, profileTransCaptureOnly, profileTransRefund, profileTransVoid' (REQUIRED))
  #       :transaction_type => { 
  #         :amount => '<amount>' (total amound of transaction ie. 1234.23 (allow a maximum of 4 digits after decimal point)(REQUIRED))
  #         :tax    => { (optional)
  #           :amount       => '<amount>' (total tax amount ie 65.34 (allow a maximum of 4 digits after decimal point))
  #           :name         => '<name>' (name of tax ie federal, state etc.)
  #           :description  => '<description>' (up to 255 characters)
  #         }
  #         :shipping => { (optional)
  #           :amount       => '<amount>' (total tax amount ie 65.34 (allow a maximum of 4 digits after decimal point))
  #           :name         => '<name>' (name of tax ie federal, state etc.)
  #           :description  => '<description>' (up to 255 characters)
  #         }  
  #         :duty => { (optional)
  #           :amount       => '<amount>' (total tax amount ie 65.34 (allow a maximum of 4 digits after decimal point))
  #           :name         => '<name>' (name of tax ie federal, state etc.)
  #           :description  => '<description>' (up to 255 characters)
  #         }  
  #         :line_items => [ (an array of items on transaction, each array item is a hash containign \/ (optional))
  #           :item_id => '<id>' (up to 31 characters)
  #           :name => '<name>' (up to 31 characters)
  #           :description => '<description>' (up to 255 characters)
  #           :quantity => <number> (up to 4 digits(and 2 decimal places... but how could you have .34 things you sold...))
  #           :unit_price => <number> (up to 4 digits(and 2 decimal places))
  #           :taxable => <boolean> (must be "true" or "false")
  #         ]
  #         :customer_profile_id          => <id number> (profile Identification number given by authorize.net (required))
  #         :customer_payment_profile_id  => <payment id number> (profile payment ID given by authorize.net (required))
  #         :customer_Shipping_address_id => <address id> (address ID given by authorize.net (optional))
  #         :trans_id                     => <number> (original transactions transId (CONDITIONAL - required for "Prior Authorization and Capture Transactions"))
  #         :credit_card_number_masked    => <numb> (last 4 digits of credit card (CONDITIONAL - require for "Refund Transactions"))
  #         :order => { (optional)
  #           :invoice_number => '<invoice number>' (up to 20 characters)
  #           :description    => '<description>' (up to 255 characters)
  #           :purchase_order_number => '<order number>' (up to 25 characters)
  #         }
  #         :tax_exempt         => <BOOLEAN> (must be "TRUE" or "FALSE"  (optional))
  #         :recurring_billing  => <BOOLEAN> (must be "TRUE" or "FALSE"  (optional))
  #         :card_code          => <num> (3 to 4 digits (Required IF merchent would like to use CCV)(optional))
  #         :split_tender_id    => <number> (up to 6 digits (conditional)(optional))
  #         :approval_code      => <code> (6 character authorication code of an original transaction (conditional - caption only transactions))
  #       }
  #     }
  #     :extra_options => <string> (information listed in name/value pair... things like customer ip address... etc(optional))
  # 
  # Returns:
  #  XML converted to hash for easy reading
  # 
  def create_customer_profile_transaction(input)
  	data = build_request('createCustomerProfileTransactionRequest') do |xml|
  	  xml.refId input[:ref_id] if input[:ref_id]
      xml.tag!('transaction') do
        xml.tag!(input[:transaction][:trans_type]) do
          xml.amount input[:transaction][:transaction_type][:amount] if input[:transaction][:transaction_type][:amount]
          if input[:transaction][:transaction_type][:tax]
            xml.tag!('tax') do
              xml.amount input[:transaction][:transaction_type][:tax][:amount] if input[:transaction][:transaction_type][:tax][:amount]
              xml.name input[:transaction][:transaction_type][:tax][:name] if input[:transaction][:transaction_type][:tax][:name]
              xml.description input[:transaction][:transaction_type][:tax][:description] if input[:transaction][:transaction_type][:tax][:description]
            end
          end
          if input[:transaction][:transaction_type][:shipping]
            xml.tag!('shipping') do
              xml.amount input[:transaction][:transaction_type][:shipping][:amount] if input[:transaction][:transaction_type][:shipping][:amount]
              xml.name input[:transaction][:transaction_type][:shipping][:name] if input[:transaction][:transaction_type][:shipping][:name]
              xml.description input[:transaction][:transaction_type][:shipping][:description] if input[:transaction][:transaction_type][:shipping][:description]
            end
          end
          if input[:transaction][:transaction_type][:duty]
            xml.tag!('duty') do
              xml.amount input[:transaction][:transaction_type][:duty][:amount] if input[:transaction][:transaction_type][:duty][:amount]
              xml.name input[:transaction][:transaction_type][:duty][:name] if input[:transaction][:transaction_type][:duty][:name]
              xml.description input[:transaction][:transaction_type][:duty][:description] if input[:transaction][:transaction_type][:duty][:description]
            end
          end
          if input[:transaction][:transaction_type][:line_item]
            xml.tag!('lineItems')  do
              arr = input[:transaction][:transaction_type][:line_item]
              arr.each { |item|
                xml.idemId item[:item_id]
                xml.name item[:name]
                xml.description item[:description]
                xml.quantity item[:quantity]
                xml.unitPrice item[:unit_price]
                xml.taxable item[:taxable]
              }
            end
          end
          xml.customerProfileId input[:transaction][:transaction_type][:customer_profile_id] if input[:transaction][:transaction_type][:customer_profile_id]
          xml.customerPaymentProfileId input[:transaction][:transaction_type][:customer_payment_profile_id] if input[:transaction][:transaction_type][:customer_payment_profile_id]
          xml.customerShippingAddressId input[:transaction][:transaction_type][:customer_shipping_address_id] if input[:transaction][:transaction_type][:customer_shipping_address_id]
          xml.transId input[:transaction][:transaction_type][:trans_id] if input[:transaction][:transaction_type][:trans_id]
          xml.creditCardNumberMasked input[:transaction][:transaction_type][:credit_card_number_masked] if input[:transaction][:transaction_type][:credit_card_number_masked]
          if input[:transaction][:transaction_type][:order]
            xml.tag!('order') do
              xml.invoiceNumber input[:transaction][:transaction_type][:order][:invoice_number] if input[:transaction][:transaction_type][:order][:invoice_number]
              xml.description input[:transaction][:transaction_type][:order][:description] if input[:transaction][:transaction_type][:order][:description]
              xml.purchaseOrderNumber input[:transaction][:transaction_type][:order][:purchase_order_number] if input[:transaction][:transaction_type][:order][:purchase_order_number]
            end
          end
          xml.taxExempt input[:transaction][:transaction_type][:tax_exempt] if input[:transaction][:transaction_type][:tax_exempt]
          xml.recurringBilling input[:transaction][:transaction_type][:recurring_billing] if input[:transaction][:transaction_type][:recurring_billing]
          xml.cardCode input[:transaction][:transaction_type][:card_code] if input[:transaction][:transaction_type][:card_code]
          xml.splitTenderId input[:transaction][:transaction_type][:split_tender_id] if input[:transaction][:transaction_type][:split_tender_id]
          xml.approvalCode input[:transaction][:transaction_type][:approval_code] if input[:transaction][:transaction_type][:approval_code]
        end
      end
      xml.extraOptions input[:extra_options] if input[:extra_options]
    end    
    parse send(data)
  end
     
  # Void a transaction.
  # 
  # perams:
  #     A hash containing all necessary fileds
  #   all possible perams:
  #         :customer_profile_id          => <id number> (profile Identification number given by authorize.net (optional))
  #         :customer_payment_profile_id  => <payment id number> (profile payment ID given by authorize.net (optional))
  #         :customer_Shipping_address_id => <address id> (address ID given by authorize.net (optional))
  #         :trans_id                     => <number> (original transactions transId (Required))
  #
  def void_transaction(input)
    data = build_request('deleteCustomerProfileRequest') do |xml|
      xml.transaction do
        xml.profileTransVoid do
      	  xml.customerProfileId input[:customer_profile_id] if input[:customer_profile_id]
          xml.customerPaymentProfileId input[:customer_payment_profile_id] if input[:customer_payment_profile_id]
          xml.customerShippingAddressId input[:customer_shipping_address_id] if input[:customer_shipping_address_id]
          xml.transId input[:trans_id] if input[:trans_id]
        end
      end
    end
    
  end

     

  # Delete an existing customer profile along with all associated customer payment profiles and customer shipping addresses.
  # 
  # perams:
  #     A hash containing all necessary fields
  #   all possible perams:
  #     :ref_id               => '<id>' (up to 20 digits (optional))
  #     :customer_profile_id  => <id of customer> (numeric (necessary))
  #
  # returns:
  #     xml converted to hash for easy access
  def delete_customer_profile(input)
  	data = build_request('deleteCustomerProfileRequest') do |xml|
  	  xml.refId input[:ref_id] if input[:ref_id]
      xml.customerProfileId input[:customer_profile_id] if input[:customer_profile_id]
    end    
    parse send(data)
  end
  
  # Delete a customer payment profile from an existing customer profile.
  # 
  # perams:
  #     A hash containing all necessary fields
  #   all possible perams:
  #     :ref_id                       => '<id>' (up to 20 digits (optional))
  #     :customer_profile_id          => <id of customer> (numeric (necessary))
  #     :customer_payment_profile_id  => <payment id> (numeric (necessary))
  # returns:
  #     xml converted to hash for easy access
  def delete_customer_payment_profile(input)
  	data = build_request('deleteCustomerPaymentProfileRequest') do |xml|
  	  xml.refId input[:ref_id] if input[:ref_id]
      xml.customerProfileId input[:customer_profile_id] if input[:customer_profile_id]
      xml.customerPaymentProfileId input[:customer_payment_profile_id] if input[:customer_payment_profile_id]
    end    
    parse send(data)
  end
    
  # Delete a customer shipping address from an existing customer profile.
  # 
  # perams:
  #     A hash containing all necessary fields
  #   all possible perams:
  #     :ref_id                       => '<id>' (up to 20 digits (optional))
  #     :customer_profile_id          => <id of customer> (numeric (necessary))
  #     :customer_address_id  => <shipping id> (numeric (necessary))
  #
  # returns:
  #     xml converted to hash for easy access
  def delete_customer_shipping_address(input)
  	data = build_request('deleteCustomerShippingAddressRequest') do |xml|
  	  xml.refId input[:ref_id] if input[:ref_id]
      xml.customerProfileId input[:customer_profile_id] if input[:customer_profile_id]
      xml.customerAddressId input[:customer_address_id] if input[:customer_address_id]
    end    
  	parse send(data)
    
  end
  
  # Retrieve all customer profile IDs you have previously created.
  # returns:
  #     xml converted to hash for easy access
  def get_customer_profile_ids
  	data = build_request('getCustomerProfileIdsRequest') {}
  	parse send(data)
  end
  
  # Retrieve an existing customer profile along with all the associated customer payment profiles and customer shipping addresses.
  # perams:
  #     A hash containing all necessary fields
  #   all possible perams:
  #     :customer_profile_id          => <id of customer> (numeric (necessary))
  def get_customer_profile(input)
  	data = build_request('getCustomerProfileRequest') do |xml|
      xml.customerProfileId input[:customer_profile_id] if input[:customer_profile_id]
    end
    parse send(data)
  	
  end
  
  # Retrieve a customer payment profile for an existing customer profile.
  # 
  # perams:
  #     A hash containing all necessary fields
  #   all possible perams:
  #     :customer_profile_id          => <id of customer> (numeric (necessary))
  #     :customer_payment_profile_id  => <payment id> (numeric (necessary))
  #
  # returns:
  #     xml converted to hash for easy access
  def get_customer_payment_profile(input)
  	data = build_request('getCustomerPaymentProfileRequest') do |xml|
      xml.customerProfileId input[:customer_profile_id] if input[:customer_profile_id]
      xml.customerPaymentProfileId input[:customer_payment_profile_id] if input[:customer_payment_profile_id]
    end    
    parse send(data)
  	
  end
  
  # Retrieve a customer shipping address for an existing customer profile.
  # perams:
  #     A hash containing all necessary fields
  #   all possible perams:
  #     :ref_id                       => '<id>' (up to 20 digits (optional))
  #     :customer_profile_id          => <id of customer> (numeric (necessary))
  #     :customer_address_id  => <shipping id> (numeric (necessary))
  #
  # returns:
  #     xml converted to hash for easy access
  def get_customer_shipping_address(input)
  	data = build_request('getCustomerShippingAddressRequest') do |xml|
      xml.customerProfileId input[:customer_profile_id] if input[:customer_profile_id]
      xml.customerAddressId input[:customer_address_id] if input[:customer_address_id]
    end    
    parse send(data)
  end
  
  # Update an existing customer profile.
  # perams:
  #   Necessary:
  #     :customer_profile_id => <id of customer> (numeric (necessary))
  #  {
  #     :merchant_id => '<some id>'  (up to 20 characters)
  #    or
  #     :description => '<some discription>' (up to 255 characters)
  #    or
  #     :email => '<emailaddress>' (up to 255 characters)
  #  }
  # return: 
  #  xml return converted to hash containing the return_code and customer_profile_id
  #     note: a return code of I00001 is good, anything else is bad
  #
  def update_customer_profile(input) 
  	data = build_request('updateCustomerProfileRequest') do |xml|
      xml.tag!('profile') do
        xml.merchantCustomerId input[:merchant_id] if input[:merchant_id]
        xml.description input[:description] if input[:description]
        xml.email input[:email] if input[:email]
        xml.customerProfileId input[:customer_profile_id] if input[:customer_profile_id]
      end
    end    
    parse send(data)
  end
  
  # Update a customer payment profile for an existing customer profile.
  # 
  # perams:
  #     A hash containing all necessary fields
  #   all possible perams:
  #     :ref_id               => '<id>' (up to 20 digits (optional))
  #     :customer_profile_id  => <id of customer> (numeric (necessary))
  #     :payment_profile      => {
  #       :bill_to => {  (optional)
  #         :first_name     => '<billing first name>' (up to 50 characters (optional))
  #         :last_name      => '<billing last name>' (up to 50 characters (optional))
  #         :company        => '<company name>' (up to 50 characters (optional))
  #         :address        => '<address>' (up to 60 characters (optional))
  #         :city           => '<city>' (up to 40 characters (optional))
  #         :state          => '<state>' (valid 2 character state code (optional))
  #         :zip            => '<zip code>' (up to 20 characters (optional))
  #         :country        => '<country>' (up to 60 characters (optional))
  #         :phone_number   => '<phone number>' (up to 25 digits (optional))
  #         :fax_number     => '<fax number>' (up to 25 digits (optional))
  #       }
  #       :payment => { (NECESSARY > must include either bank info or credit card info)
  #         :credit_card => { (necessary if there is no bank_account in payment hash)
  #           :card_number      => <number> (13 to 16 digits (necessary))
  #           :expiration_date  => '<YYYY-MM>' (has to be 4 digit year, dash line, then 2 digit month (necessary))
  #           :card_code        => <number> (3 or 4 digit number on back of card (optional))
  #         }
  #         :bank_account => { (necessary if there is no credit_card in payment hash)
  #           :account_type     => '<type of account>' (must be "checking", "savings", or "businessChecking" (necessary))
  #           :routing_number   => <number> (9 digit bank routing number (necessary))
  #           :account_number   => <number> (5 to 17 digit number (necessary))
  #           :name_on_account  => '<name>' (up to 22 characters (necessary))
  #           :echeck_type      => '<type>' (needs to be 'CCD', 'PPD', 'TEL', or 'WEB' (optional))
  #           :bank_name        => '<bank name>' (up to 50 characters (optional))
  #         }
  #       }
  #       
  #     }
  #     :customer_payment_profile_id  => <payment id> (numeric (necessary))
  #     :validation_mode => '<mode>' (needs to be 'none', 'testMode', 'liveMode', or 'oldLiveMode' (necessary))
  # 
  # returns:
  #   xml converted to hash table for easy access
  # 
  def update_customer_payment_profile(input)
  	data = build_request('updateCustomerPaymentProfileRequest') do |xml|
  	  xml.refId input[:ref_id] if input[:ref_id]
      xml.customerProfileId input[:customer_profile_id] if input[:customer_profile_id]
      xml.tag!('paymentProfile') do
        if input[:payment_profile][:bill_to]
          xml.tag!('billTo') do
            xml.firstName input[:payment_profile][:bill_to][:first_name] if input[:payment_profile][:bill_to][:first_name]
            xml.lastName input[:payment_profile][:bill_to][:last_name] if input[:payment_profile][:bill_to][:last_name]
            xml.company input[:payment_profile][:bill_to][:company] if input[:payment_profile][:bill_to][:company]
            xml.address input[:payment_profile][:bill_to][:address] if input[:payment_profile][:bill_to][:address]
            xml.city input[:payment_profile][:bill_to][:city] if input[:payment_profile][:bill_to][:city]
            xml.state input[:payment_profile][:bill_to][:state] if input[:payment_profile][:bill_to][:state]
            xml.zip input[:payment_profile][:bill_to][:zip] if input[:payment_profile][:bill_to][:zip]
            xml.country input[:payment_profile][:bill_to][:country] if input[:payment_profile][:bill_to][:country]
            xml.phoneNumber input[:payment_profile][:bill_to][:phone_number] if input[:payment_profile][:bill_to][:phone_number]
            xml.faxNumber input[:payment_profile][:bill_to][:fax_number] if input[:payment_profile][:bill_to][:fax_number]
          end
        end
        xml.tag!('payment') do
          if input[:payment_profile][:payment][:credit_card]
            xml.tag!('creditCard') do
              xml.cardNumber input[:payment_profile][:payment][:credit_card][:card_number] if input[:payment_profile][:payment][:credit_card][:card_number]
              xml.expirationDate input[:payment_profile][:payment][:credit_card][:expiration_date] if input[:payment_profile][:payment][:credit_card][:expiration_date]
              xml.cardCode input[:payment_profile][:payment][:credit_card][:card_code] if input[:payment_profile][:payment][:credit_card][:card_code]
            end
          elsif input[:payment_profile][:payment][:bank_account]
            xml.tag!('bankAccount') do
              xml.accountType input[:payment_profile][:payment][:bank_account][:account_type] if input[:payment_profile][:payment][:bank_account][:account_type]
              xml.routingNumber input[:payment_profile][:payment][:bank_account][:routing_number] if input[:payment_profile][:payment][:bank_account][:routing_number]
              xml.accountNumber input[:payment_profile][:payment][:bank_account][:account_number] if input[:payment_profile][:payment][:bank_account][:account_number]
              xml.nameOnAccount input[:payment_profile][:payment][:bank_account][:name_on_account] if input[:payment_profile][:payment][:bank_account][:name_on_account]
              xml.echeckType input[:payment_profile][:payment][:bank_account][:echeck_type] if input[:payment_profile][:payment][:bank_account][:echeck_type]
              xml.bankName input[:payment_profile][:payment][:bank_account][:bank_name] if input[:payment_profile][:payment][:bank_account][:bank_name]
            end
          end
        end
        xml.customerPaymentProfileId input[:customer_payment_profile_id] if input[:customer_payment_profile_id]
        xml.validationMode input[:payment_profile][:validation_mode] if input[:payment_profile][:validation_mode]
      end
    end    
    parse send(data)
  end
  
  # Update a shipping address for an existing customer profile.
  # 
  # perams:
  #     A hash containing all necessary fields
  #   all possible perams:
  #     :ref_id               => '<id>' (up to 20 digits (optional))
  #     :customer_profile_id  => <id of customer> (numeric (necessary))
  #     :address => {  (a hash containing address information(necessary)
  #       :first_name     => '<billing first name>' (up to 50 characters (optional))
  #       :last_name      => '<billing last name>' (up to 50 characters (optional))
  #       :company        => '<company name>' (up to 50 characters (optional))
  #       :address        => '<address>' (up to 60 characters (optional))
  #       :city           => '<city>' (up to 40 characters (optional))
  #       :state          => '<state>' (valid 2 character state code (optional))
  #       :zip            => '<zip code>' (up to 20 characters (optional))
  #       :country        => '<country>' (up to 60 characters (optional))
  #       :phone_number   => '<phone number>' (up to 25 digits (optional))
  #       :fax_number     => '<fax number>' (up to 25 digits (optional))
  #       :customer_address_id  => <shipping id> (numeric (necessary))
  #     }
  #
  # returns:
  #   xml converted to hash table for easy access
  def update_customer_shipping_address(input)
  	data = build_request('updateCustomerShippingAddressRequest') do |xml|
  	  xml.refId input[:ref_id] if input[:ref_id]
      xml.customerProfileId input[:customer_profile_id] if input[:customer_profile_id]
      xml.tag!('address') do
        xml.firstName input[:address][:first_name] if input[:address][:first_name]
        xml.lastName input[:address][:last_name] if input[:address][:last_name]
        xml.company input[:address][:company] if input[:address][:company]
        xml.address input[:address][:address] if input[:address][:address]
        xml.city input[:address][:city] if input[:address][:city]
        xml.state input[:address][:state] if input[:address][:state]
        xml.zip input[:address][:zip] if input[:address][:zip]
        xml.country input[:address][:country] if input[:address][:country]
        xml.phoneNumber input[:address][:phone_number] if input[:address][:phone_number]
        xml.faxNumber input[:address][:fax_number] if input[:address][:fax_number]
        xml.customerAddressId input[:address][:customer_address_id] if input[:address][:customer_address_id]
      end
    end    
    parse send(data)
  end
  
# # Update the status of a split tender group (a group of transactions, each of which pays for part of one order).
#   def update_split_tender_group(input)
#     data = build_request('updateSplitTenderGroupRequest') do |xml|
# 
#       DONT WANNA DO IT
#     
#     end    
#     parse send(data)
#   end
  
# Verify an existing customer payment profile by generating a test transaction.
  def validate_customer_payment_profile(input)
  	data = build_request('validateCustomerPaymentProfileRequest') do |xml|
      xml.customerProfileId input[:customer_profile_id] if input[:customer_profile_id]
      xml.customerPaymentProfileId input[:customer_payment_profile_id] if input[:customer_payment_profile_id]
      xml.customerAddressId input[:customer_address_id] if input[:customer_address_id]
      xml.cardCode input[:card_code] if input[:card_code]
      xml.validationMode input[:validation_mode] if input[:validation_mode]
    end    
    parse send(data)
  end
   
# Create request head that is required for all requests.
#
# perams: 
#   request string
#   block of code containing all the additional xml code
#
# return:
#   completed xml as a string
#
  def build_request(request, xml = Builder::XmlMarkup.new(:indent => 2))
    xml.instruct!
    xml.tag!(request, :xmlns => 'AnetApi/xml/v1/schema/AnetApiSchema.xsd') do
      xml.tag!('merchantAuthentication') do
        xml.name @login
        xml.transactionKey @key
      end
      yield(xml)
    end
    xml.target!
  end
  
  # parse all xml documents given back from the API
  # return:
  #   hash containing all values from the xml doc
  def parse(xml)
    Crack::XML.parse(xml)
  end
  
  # get the response code from any response.
  #
  # prerams:
  #   response xml already parsed to hash  
  # returns:
  #   string - response code (something like "I00001" or "E00039")
  def response_code(hash)
    hash[hash.keys[0]]['messages']['message']['code']
  end
  
  # get the response code from any response.
  #
  # prerams:
  #   response xml already parsed to hash  
  # returns:
  #   string - response text (should be something like "Successful." or some long explaination why we it didnt work)
  def response_text(hash)
    hash[hash.keys[0]]['messages']['message']['text']
  end

  
  def send(xml) # returns xmlDoc of response
    http = Net::HTTP.new(@uri.host, @uri.port)
    http.use_ssl = 443 == @uri.port
    begin
      resp, body = http.post(@uri.path, xml, {'Content-Type' => 'text/xml'})
    rescue   Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError, Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => e
      puts e.message      
    end
    body
  end
  
end