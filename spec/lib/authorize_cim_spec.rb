require "#{File.dirname(__FILE__)}/../base"

describe AuthorizeCim do
  
  before do
    @client = AuthorizeCim.new(:endpoint => :test, :login => '3wFY26cE', :key => '5W22d4Jk4De6v6XJ')
  end
  
  before :each do
    hash = { :merchant_id => 'Lyon Hill', :description => 'Test User, should be deleted', :email => 'lyon@delorum.com'}
    rtn = @client.create_customer_profile(hash)
    @customer_profile = rtn['createCustomerProfileResponse']['customerProfileId']

    hash2 = {:customer_profile_id => @customer_profile, :validation_mode => 'none', :payment_profile => {}}
    hash2[:payment_profile] = {:customer_type => 'business', :payment => {}}
    hash2[:payment_profile][:payment] = {:credit_card => {}}
    hash2[:payment_profile][:payment][:credit_card] = {:card_number => '4007000000027', :expiration_date => '2011-03'}
    rtn2 = @client.create_customer_payment_profile(hash2)
    @customer_payment_profile = rtn2['createCustomerPaymentProfileResponse']['customerPaymentProfileId']
    
    hash3 = {:customer_profile_id => @customer_profile, :address => {}}
    hash3[:address] = {
      :first_name => 'Lyon', 
      :last_name => 'Hill', 
      :company => 'Delorum', 
      :address => '218 N 2nd E', 
      :city => 'Rexburg',
      :state => 'ID',
      :zip => '83440',
      :country => 'United States Of America',
      :phone_number => '2086810512',
      :fax_number => '(208)359-1103'}
    rtn3 = @client.create_customer_shipping_address(hash3)
    @customer_address_profile = rtn3['createCustomerShippingAddressResponse']['customerAddressId']
  end
  
  after :each do
    hash4 = {:customer_profile_id => @customer_profile}
    @client.delete_customer_profile(hash4)

  end
  
  it "creates a valid customer profile" do
    thing = { :merchant_id => 'guy', :description => 'o GOODNESS!', :email => 'lyon@delorum.com'}
    item = @client.create_customer_profile(thing)
    item['createCustomerProfileResponse']['messages']['message']['code'].should == 'I00001'
    kill = item['createCustomerProfileResponse']['customerProfileId']
    @client.delete_customer_profile({:customer_profile_id => @customer_profile})
  end

  it "should fail to create a valid customer profile when it recieves invalid input" do
    thing = {:useless_stuff => 'HAY, Im not useless :_('}
    item = @client.create_customer_profile(thing)
    item['createCustomerProfileResponse']['messages']['message']['code'].should_not == 'I00001'
  end
  
  it "create Customer payment profile with the minimum requirements" do
    hash = {:customer_profile_id => @customer_profile, :validation_mode => 'none', :payment_profile => {}}
    hash[:payment_profile] = {:customer_type => 'business', :payment => {}}
    hash[:payment_profile][:payment] = {:credit_card => {}}
    hash[:payment_profile][:payment][:credit_card] = {:card_number => '1234567890123456', :expiration_date => '2011-03'}
    pay_profile_return = @client.create_customer_payment_profile(hash)
    pay_profile_return['createCustomerPaymentProfileResponse']['messages']['message']['code'].should == 'I00001'
  end

  it "create Customer payment profile with the maximum allowed fields" do
    hash = {:ref_id => 'letters', :customer_profile_id => @customer_profile, :validation_mode => 'none', :payment_profile => {}}
    hash[:payment_profile] = {:customer_type => 'business', :payment => {}, :bill_to => {}}
    hash[:payment_profile][:bill_to] = {:first_name => 'Lyon', :last_name => 'Hill', :company => 'Delorum', :address => '185 N 2000 E', :city => 'Rexburg', :state => 'ID', :zip => '83440', :country => 'USA', :phone_number => 2083591103, :fax_number => 2085895149}
    hash[:payment_profile][:payment] = {:credit_card => {}}
    hash[:payment_profile][:payment][:credit_card] = {:card_number => '1234567890123456', :expiration_date => '2011-03'}
    pay_profile_return = @client.create_customer_payment_profile(hash)
    pay_profile_return['createCustomerPaymentProfileResponse']['messages']['message']['code'].should == 'I00001'
  end

  it "create a valid customer shipping address" do
    hash = {:customer_profile_id => @customer_profile, :address => {}}
    hash[:address] = {:first_name => 'Tyler', :last_name => 'Flint', :company => 'Delorum', :address => '23 N 2nd E', :city => 'Rexburg', :state => 'ID', :zip => '83440', :country => 'USA', :phone_number => 2083598909, :fax_number => 2082315149}
    address_return = @client.create_customer_shipping_address(hash)
    address_return['createCustomerShippingAddressResponse']['messages']['message']['code'].should == 'I00001'
  end
  

  it "create a valid customer profile transaction" do
    hash = {:ref_id => '2', :transaction => {}}
    hash[:transaction] = {:trans_type => 'profileTransAuthCapture', :transaction_type => {}}
    hash[:transaction][:transaction_type] = {:amount => '101.11', :customer_profile_id => @customer_profile , :customer_payment_profile_id => @customer_payment_profile, :tax => {}}
    hash[:transaction][:transaction_type][:tax] = {:amount => '23.21', :name => 'state taxes'}
    transaction = @client.create_customer_profile_transaction(hash)
    transaction['createCustomerProfileTransactionResponse']['messages']['message']['code'].should == 'I00001'
  end
  
  it "should get customer profile IDs" do
    all_customer_profile_ids = @client.get_customer_profile_ids
    all_customer_profile_ids['getCustomerProfileIdsResponse']['messages']['message']['code'].should == 'I00001'
  end

  it "should get all of one customers profile info" do
    hash = {:customer_profile_id => @customer_profile}
    one_customer_info = @client.get_customer_profile(hash)
    one_customer_info['getCustomerProfileResponse']['messages']['message']['code'].should == 'I00001'
  end
    
  it "should get one customers payment profile(s)" do
    one_customer_payment = @client.get_customer_payment_profile({:customer_profile_id => @customer_profile, :customer_payment_profile_id => @customer_payment_profile})
    one_customer_payment['getCustomerPaymentProfileResponse']['messages']['message']['code'].should == 'I00001'
  end

  it "should get one customers shipping address" do
    one_customer_shipping = @client.get_customer_shipping_address({:customer_profile_id => @customer_profile, :customer_address_id => @customer_address_profile})
    one_customer_shipping['getCustomerShippingAddressResponse']['messages']['message']['code'].should == 'I00001'
  end
  
  it "should update a customer profile" do
    hash = {:customer_profile_id => @customer_profile, :merchant_id => 'John Wayne'}
    update_customer = @client.update_customer_profile(hash)
    update_customer['updateCustomerProfileResponse']['messages']['message']['code'].should == 'I00001'
  end
    
  it "should update customer payment profile" do
    hash = {:customer_profile_id => @customer_profile, :customer_payment_profile_id => @customer_payment_profile, :validation_mode => 'none', :payment_profile => {}}
    hash[:payment_profile] = {:customer_type => 'business', :payment => {}}
    hash[:payment_profile][:payment] = {:credit_card => {}}
    hash[:payment_profile][:payment][:credit_card] = {:card_number => '1234567890123456', :expiration_date => '2011-03'}
    pay_profile_return = @client.update_customer_payment_profile(hash)
    pay_profile_return['updateCustomerPaymentProfileResponse']['messages']['message']['code'].should == 'I00001'
  end
  

  it "should update customer shipping address" do
    hash3 = {:customer_profile_id => @customer_profile, :address => {}}
    hash3[:address] = {
      :first_name => 'Lyon', 
      :last_name => 'Hill', 
      :company => 'Delorum', 
      :address => '218 N 2nd E', 
      :city => 'Rexburg',
      :state => 'ID',
      :zip => '83440',
      :country => 'United States Of America',
      :phone_number => '2086810512',
      :fax_number => '(208)359-1103',
      :customer_address_id => @customer_address_profile }
    
  end
  
  it "should validate Customer Payment Profile Request" do
    
  end
  
  it "should parse return statements for all xml returns except the get functions" do
    xml = <<EOF
    <?xml version="1.0" encoding="utf-8"?>
    <createCustomerProfileResponse xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns="AnetApi/xml/v1/schema/AnetApiSchema.xsd">
    	<messages>
    		<resultCode>Ok</resultCode>
    		<message>
    			<code>I00001</code>
    			<text>Successful.</text>
    		</message>
    	</messages>
    	<customerProfileId>2667736</customerProfileId>
    	<customerPaymentProfileIdList />
    	<customerShippingAddressIdList />
    	<validationDirectResponseList />
    </createCustomerProfileResponse>
EOF

  item = @client.parse(xml) 
	item['createCustomerProfileResponse']['messages']['message']['code'].should == 'I00001'
	item['createCustomerProfileResponse']['customerProfileId'].should == '2667736'
  end
  
  it "should delete a customer profile" do
    hash = {:customer_profile_id => @customer_profile}
    rtn = @client.delete_customer_profile(hash)
    rtn['deleteCustomerProfileResponse']['messages']['message']['code'].should == 'I00001'
    
  end
  
  it "should delete a customer payment profile" do
    hash = {:customer_profile_id => @customer_profile, :customer_payment_profile_id => @customer_payment_profile}
    rtn = @client.delete_customer_profile(hash)
    rtn['deleteCustomerProfileResponse']['messages']['message']['code'].should == 'I00001'
    
  end
  
  it "should delete a customer shipping address" do
    hash = {:customer_profile_id => @customer_profile, :customer_address_id => @customer_address_profile}
    rtn = @client.delete_customer_profile(hash)
    rtn['deleteCustomerProfileResponse']['messages']['message']['code'].should == 'I00001'
    
  end
  
  it "should get the response code from the hash" do
    xml = "<?xml version=\"1.0\" encoding=\"utf-8\"?><createCustomerProfileResponse xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns=\"AnetApi/xml/v1/schema/AnetApiSchema.xsd\"><messages><resultCode>Ok</resultCode><message><code>I00001</code><text>Successful.</text></message></messages><customerProfileId>2688406</customerProfileId><customerPaymentProfileIdList /><customerShippingAddressIdList /><validationDirectResponseList /></createCustomerProfileResponse>"
    hash = @client.parse(xml)
    "I00001".should == @client.response_code(hash)
  end
  
  it "should get the plain text response from the hash" do
    xml = "<?xml version=\"1.0\" encoding=\"utf-8\"?><createCustomerProfileResponse xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns=\"AnetApi/xml/v1/schema/AnetApiSchema.xsd\"><messages><resultCode>Ok</resultCode><message><code>I00001</code><text>Successful.</text></message></messages><customerProfileId>2688406</customerProfileId><customerPaymentProfileIdList /><customerShippingAddressIdList /><validationDirectResponseList /></createCustomerProfileResponse>"
    hash = @client.parse(xml)
    "Successful.".should == @client.response_text(hash)
  end
end