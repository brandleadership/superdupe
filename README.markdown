## SuperDupe
SuperDupe provides two things:

 * Mock ActiveResource objects like the originally gem dupe
 * Superdupe send no requests to external services registerd by the ARes. It has an extra parameter to send explicitly extrnal requests.

SuperDupe is a fork of the originally gem dupe 0.5.1 (Matt Parker). At first, the gem try to use only the available mocked resources. If you have the requirement to send external requests without mocking, take an extra parameter for this situation.

# Install the gem
    gem install superdupe
    
# Usage
*Implemented ActiveResource class*
    class Customer < ActiveResource::Base
      self.site = ''
    end

*Register a mock response*
    Dupe.create <class_name>, <attributes>
    Dupe.create Customer, :name => 'test customer'
    
*Find a registered object*
    Customer.find 1
    
*Find all registered objects*
    Customer.find :all
    
*Find registered url patterns*
    Dupe.network.mocks[<http-method>]
    Dupe.network.mocks[:get]
    
*Register a custom mock with a param-filter*
    Get %r{\/customers\.xml\?state=(active|inactive)} do |state|
      if state == 'active'
        Dupe.find(:"Customers") {|c| c.state == 'active'}
      else
        Dupe.find(:"Customers") {|c| c.state == 'inactive'}
      end
    end
    # Register a custom mock with the entered url pattern