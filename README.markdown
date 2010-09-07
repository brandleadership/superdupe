## SuperDupe
SuperDupe provides two things:

 * Mock ActiveResource objects like the originally gem dupe
 * Superdupe send no requests to external services registerd by the ARes. It has an extra parameter to send explicitly extrnal requests.

SuperDupe is a fork of the originally gem dupe 0.5.1 (Matt Parker). At first, the gem try to use only the available mocked resources. If you have the requirement to send external requests without mocking, take an extra parameter for this situation.

# Install the gem
    gem install superdupe
    
# Usage
 
 * Register a mock
 
    Dupe.create <class_name>, <attributes>
    Dupe.create Customer, :name => 'test customer'