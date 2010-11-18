require "#{File.dirname(__FILE__)}/../base"

describe AuthorizeCim do
  
  before do
    @client = AuthorizeCim.new(:endpoint => :test, :login => '3wFY26cE', :key => '5W22d4Jk4De6v6XJ')
  end
  
  it "should require key when itializing" do
    
  end
  
  it "should require a login when initializing" do
    
  end
  
  it "creates a valid customer profile" do
    
  end

  it "should fail to create a valid customer profile when it recieves invalid input" do
    
  end
  
  it "create Customer payment profile" do
    
  end

  it "shoud fail to create a valid customer payment profile when it recieves invalid input" do
    
  end
  
  it "create a valid customer shipping address" do
    
  end
  
  it "should fail to create a valid customer shipping address when it recieves invalid input" do
    
  end
  
  it "create a valid customer profile transaction" do
    
  end
  
  it "should fail to create a valid customer profile transaction when it recieves invalid input" do
    
  end
  
  it "should delete a customer profile" do
    
  end
  
  it "should fail to delete a customer profile when given invalid input" do
    
  end
  
  it "should delete a customer payment profile" do
    
  end
  
  it "should fail to delete a customer payment profile when given invalid input" do
    
  end
  
  it "should delete a customer shipping address" do
    
  end
  
  it "should fail to delete a customer shipping address when given invalid input" do
    
  end
  
  it "should get customer profile IDs" do
    
  end
  
  it "should fail to get customer profile IDs when given incorrect input" do
    
  end
  
  it "should get all of one customers profile info" do
    
  end
  
  it "should fail to get all of one customers profile info when given invalid input" do
    
  end
  
  it "should get one customers payment profile(s)" do
    
  end

  it "should fail to get one customers payment profile(s) when given invalid input" do
    
  end
  
  it "should get one customers shipping address" do
    
  end
  
  it "should fail to get one customers shipping address when given invalid input" do
    
  end
  
  it "should update a customer profile" do
    
  end
  
  it "should fail to update a customer profile when given invalid input" do
    
  end
  
  it "should update customer payment profile" do
    
  end
  
  it "should fail to update customer payment profile when given invalid input" do
    
  end
  
  it "should update customer shipping address" do
    
  end
  
  it "should fail to update customer shipping address when given invalid input" do
    
  end
  
  it "update split tender group request" do
    
  end
  
  it "update fail to split tender group request when given invalid input" do
    
  end
  
  it "should validate Customer Payment Profile Request" do
    
  end
  
  it "should fail to validate Customer Payment Profile Request when given invalid input" do
    
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
    item = client.parse(REXML::Document.new(xml)) 
	
	item[:code].should == 'I00001'
	item[:customerProfileId].should == '2667736'
	

  end
  
  #parse for get functions
  
  it "should parse the customer id list given back to the 'getCustomerProfileIds' function" do
    
  end

  it "should parse the customer profile given back to the 'getCustomerProfile' function" do
    
  end
  
  it "should parse the customer payment profile(s) given back to the 'getCustomerPaymentProfile' function" do
    
  end
  
  it "should parse the customer shipping address given back to the 'getCustomerShippingAddress' function" do
    
  end

  
end