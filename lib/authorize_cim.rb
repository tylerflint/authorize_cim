class InvalidOrMissingCredentials < Exception; end

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
    
      
  end

# Create a new customer profile along with 
# any customer payment profiles and customer shipping addresses for the customer profile.
#
# REQUIREMENTS atleast an Email address saved in the has as a :email.
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
#  a hash containing the return_code and customer_profile_id
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
  def create_customer_payment_profile()
    
  end
  
# Create a new customer shipping address for an existing customer profile. You can create up to 100 customer shipping addresses for each customer profile.
  def create_customer_shipping_address()
    
  end
  
# Create a new payment transaction from an existing customer profile.
  def create_customer_profile_transaction()
    
  end
     
# Delete an existing customer profile along with all associated customer payment profiles and customer shipping addresses.
  def delete_customer_profile()
    
  end
  
# Delete a customer payment profile from an existing customer profile.
  def delete_customer_payment_profile()
    
  end
    
# Delete a customer shipping address from an existing customer profile.
  def delete_customer_shipping_address()
    
  end
  
# Retrieve all customer profile IDs you have previously created.
  def get_customer_profile_ids()
    
  end
  
# Retrieve an existing customer profile along with all the associated customer payment profiles and customer shipping addresses.
  def get_customer_profile()
    
  end
  
# Retrieve a customer payment profile for an existing customer profile.
  def get_customer_payment_profile()
    
  end
  
# Retrieve a customer shipping address for an existing customer profile.
  def get_customer_shipping_address()
    
  end
  
# Update an existing customer profile.
  def update_customer_profile() 
    
  end
  
# Update a customer payment profile for an existing customer profile.
  def update_customer_payment_profile()
    
  end
  
# Update a shipping address for an existing customer profile.
  def update_customer_shipping_address()
    
  end
  
# Update the status of a split tender group (a group of transactions, each of which pays for part of one order).
  def update_split_tender_group()
    
  end
  
# Verify an existing customer payment profile by generating a test transaction.
  def validate_customer_payment_profile()
    
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
  def request_head(request, xml = Builder::XmlMarkup.new(:indent => 2))
    xml.instruct!
    xml.tag!(request, :xmlns => 'AnetApi/xml/v1/schema/AnetApiSchema.xsd') do
      xml.tag!('merchantAuthentication') do
        xml.name @login
        xml.transactionKey @password
      end
      yield(xml)
    end
    xml.target!
  end
  
# parse all xml documents given back from the API
# return:
#   hash containing all values from the xml doc
  def parse(xml)
	code  				= REXML::XPath.first(xml.root, '/*/messages/code').text
	profile_id			= REXML::XPath.first(xml.root, '/*/customerProfileId').text
	trans_id			= REXML::XPath.first(xml.root, '/*/customerTransactionId').text
	payment_profile_id 	= REXML::XPath.first(xml.root, '/*/customerPaymentProfileId').text
	address_id	 		= REXML::XPath.first(xml.root, '/*/customerAddressId').text
	direct_response 	= REXML::XPath.first(xml.root, '/*/directResponse').text
	Hash.from_xml(xml)
	

  end
  
  
  def send(xml) # returns xmlDoc of response
    http = Net::HTTP.new(@endpoint.host, @endpoint.port)
    http.use_ssl = 443 == @endpoint.port
    resp, body = http.post(@endpoint.path, xml, {'Content-Type' => 'text/xml'})
    REXML::Document.new(body)
  end
  
  
end
