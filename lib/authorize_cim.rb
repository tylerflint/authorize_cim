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
# 
# 
  def create_customer_payment_profile(input)
  	data = build_request('createCustomerPaymentProfileRequest') do |xml|
  	  xml.refId input[:ref_id] if input[:ref_id]
      xml.customerProfileId input[:customer_profile_id] if input[:customer_profile_id]
      xml.tag!('paymentProfile') do
        if item[:payment_profile].has_token?(:bill_to)
          xml.firstName item[:payment_profile][:bill_to][:first_name] if item[:payment_profile][:bill_to][:first_name]
          xml.lastName item[:payment_profile][:bill_to][:last_name] if item[:payment_profile][:bill_to][:last_name]
          xml.company item[:payment_profile][:bill_to][:company] if item[:payment_profile][:bill_to][:company]
          xml.address item[:payment_profile][:bill_to][:address] if item[:payment_profile][:bill_to][:address]
          xml.city item[:payment_profile][:bill_to][:city] if item[:payment_profile][:bill_to][:city]
          xml.state item[:payment_profile][:bill_to][:state] if item[:payment_profile][:bill_to][:state]
          xml.zip item[:payment_profile][:bill_to][:zip] if item[:payment_profile][:bill_to][:zip]
          xml.country item[:payment_profile][:bill_to][:country] if item[:payment_profile][:bill_to][:country]
          xml.phoneNumber item[:payment_profile][:bill_to][:phone_number] if item[:payment_profile][:bill_to][:phone_number]
          xml.faxNumber item[:payment_profile][:bill_to][:fax_number] if item[:payment_profile][:bill_to][:fax_number]
        end
        xml.tag!('payment') do
          if item[:payment_profile][:payment].has_token?(:credit_card)
            xml.tag!('creditCard') do
              xml.cardNumber item[:payment_profile][:payment][:credit_card][:card_number] if item[:payment_profile][:payment][:credit_card][:card_number]
              xml.expirationDate item[:payment_profile][:payment][:credit_card][:expiration_date] if item[:payment_profile][:payment][:credit_card][:expiration_date]
              xml.cardCode item[:payment_profile][:payment][:credit_card][:card_code] if item[:payment_profile][:payment][:credit_card][:card_code]
            end
          elsif item[:payment_profile][:payment].has_token?(:bank_account)
            xml.tag!('bankAccount') do
              xml.accountType item[:payment_profile][:payment][:bank_account][:account_type] if item[:payment_profile][:payment][:bank_account][:account_type]
              xml.routingNumber item[:payment_profile][:payment][:bank_account][:routing_number] if item[:payment_profile][:payment][:bank_account][:routing_number]
              xml.accountNumber item[:payment_profile][:payment][:bank_account][:account_number] if item[:payment_profile][:payment][:bank_account][:account_number]
              xml.nameOnAccount item[:payment_profile][:payment][:bank_account][:name_on_account] if item[:payment_profile][:payment][:bank_account][:name_on_account]
              xml.echeckType item[:payment_profile][:payment][:bank_account][:echeck_type] if item[:payment_profile][:payment][:bank_account][:echeck_type]
              xml.bankName item[:payment_profile][:payment][:bank_account][:bank_name] if item[:payment_profile][:payment][:bank_account][:bank_name]
            end
          end
        end
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
        xml.firstName item[:address][:first_name] if item[:address][:first_name]
        xml.lastName item[:address][:last_name] if item[:address][:last_name]
        xml.company item[:address][:company] if item[:address][:company]
        xml.address item[:address][:address] if item[:address][:address]
        xml.city item[:address][:city] if item[:address][:city]
        xml.state item[:address][:state] if item[:address][:state]
        xml.zip item[:address][:zip] if item[:address][:zip]
        xml.country item[:address][:country] if item[:address][:country]
        xml.phoneNumber item[:address][:phone_number] if item[:address][:phone_number]
        xml.faxNumber item[:address][:fax_number] if item[:address][:fax_number]
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
#       :transaction_type => { '<transType>' (must be "profileTransAuthOnly", "profileTransAuthCapture", "profileTransCaptureOnly", (REQUIRED))
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
#           :itemId => '<id>' (up to 31 characters)
#           :name => '<name>' (up to 31 characters)
#           :description => '<description>' (up to 255 characters)
#           :quantity => <number> (up to 4 digits(and 2 decimal places... but how could you have .34 things you sold...))
#           :unit_price => <number> (up to 4 digits(and 2 decimal places))
#           :taxable => <boolean> (must be "true" or "false")
#         ]
#         :customer_profile_id          => <id number> (profile Identification number given by authorize.net)
#         :customer_payment_profile_id  => <payment id number> (profile payment ID given by authorize.net)
#         :customer_Shipping_address_id => <address id> (address ID given by authorize.net)
#         :order => { (optional)
#           :invoice_number => '<invoice number>' (up to 20 characters)
#           :description    => '<description>' (up to 255 characters)
#           :purchase_order_number => '<order number>' (up to 25 characters)
#         }
#         :tax_exempt         => <BOOLEAN> (must be "TRUE" or "FALSE"  (optional))
#         :recurring_billing  => <BOOLEAN> (must be "TRUE" or "FALSE"  (optional))
#         :card_code          => <num> (3 to 4 digits (Required IF merchent would like to use CCV)(optional))
#         :split_tender_id    => <number> (up to 6 digits (conditional)(optional))
#       }
#     }
#     :extra_options => <string> (information listed in name/value pair... things like customer ip address... etc(optional))
# 
# Returns:
#  XML converted to hash for easy reading
# 
  def create_customer_profile_transaction(input)
  	data = build_request('createCustomerProfileTransactionRequest') do |xml|


    end    
    
  end
     
# Delete an existing customer profile along with all associated customer payment profiles and customer shipping addresses.
  def delete_customer_profile(input)
  	data = build_request('deleteCustomerProfileRequest') do |xml|


    end    
    
  end
  
# Delete a customer payment profile from an existing customer profile.
  def delete_customer_payment_profile(input)
  	data = build_request('deleteCustomerPaymentProfileRequest') do |xml|


    end    
    
  end
    
# Delete a customer shipping address from an existing customer profile.
  def delete_customer_shipping_address(input)
  	data = build_request('deleteCustomerShippingAddressRequest') do |xml|


    end    
    
  end
  
# Retrieve all customer profile IDs you have previously created.
  def get_customer_profile_ids(input)
  	data = build_request('getCustomerProfileIdsRequest') do |xml|


    end    
    
  end
  
# Retrieve an existing customer profile along with all the associated customer payment profiles and customer shipping addresses.
  def get_customer_profile(input)
  	data = build_request('getCustomerProfileRequest') do |xml|


    end    
    
  end
  
# Retrieve a customer payment profile for an existing customer profile.
  def get_customer_payment_profile(input)
  	data = build_request('getCustomerPaymentProfileRequest') do |xml|


    end    
    
  end
  
# Retrieve a customer shipping address for an existing customer profile.
  def get_customer_shipping_address(input)
  	data = build_request('getCustomerShippingAddressRequest') do |xml|


    end    
    
  end
  
# Update an existing customer profile.
  def update_customer_profile(input) 
  	data = build_request('updateCustomerProfileRequest') do |xml|


    end    
    
  end
  
# Update a customer payment profile for an existing customer profile.
  def update_customer_payment_profile(input)
  	data = build_request('updateCustomerPaymentProfileRequest') do |xml|


    end    
    
  end
  
# Update a shipping address for an existing customer profile.
  def update_customer_shipping_address(input)
  	data = build_request('updateCustomerShippingAddressRequest') do |xml|


    end    
    
  end
  
# Update the status of a split tender group (a group of transactions, each of which pays for part of one order).
  def update_split_tender_group(input)
  	data = build_request('updateSplitTenderGroupRequest') do |xml|


    end    
    
  end
  
# Verify an existing customer payment profile by generating a test transaction.
  def validate_customer_payment_profile(input)
  	data = build_request('validateCustomerPaymentProfileRequest') do |xml|


    end    
    
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
  
  
  def send(xml) # returns xmlDoc of response
    http = Net::HTTP.new(@uri.host, @uri.port)
    http.use_ssl = 443 == @uri.port
    resp, body = http.post(@uri.path, xml, {'Content-Type' => 'text/xml'})
    body
  end
  
end
