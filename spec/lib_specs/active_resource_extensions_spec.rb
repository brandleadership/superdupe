require 'spec_helper'

class Customer < ActiveResource::Base
  self.site = ''
end

describe Customer do
  before(:each) do
    Dupe.reset
  end
  
  it "should have none url patterns registered" do
    [:post, :get, :delete, :put].each do |verb|
      Dupe.network.mocks[verb].should be_blank
    end
  end
  
  
  context "registerd" do
    before(:each) do
      Dupe.create Customer, :name => 'Ribi', :state => 'active'
    end
  
    it "should be registered as get mock" do
      Dupe.network.mocks[:get].size == 2
    end
  
    it "should generate a GetMock" do
      customer = Dupe.find :"Customer"
      customer.should_not be_nil
      customer.class.should == Dupe::Database::Record
    end
    
    it "should generate a valid url pattern" do
      Dupe.network.mocks[:get].each_with_index do |mock, index|
        mock.url_pattern.class.should == Regexp
        if index == 0
          mock.url_pattern.inspect.should == (%r{^\/customers\.xml$}).inspect
        else
          mock.url_pattern.inspect.should == %r{^\/customers\/(\d+)\.xml$}.inspect
        end      
      end
    end
    
    
    context "find single resource" do
      before(:each) { @customer = Customer.find 1 }
      
      it "should find customer with id 1" do
        @customer.should_not be_blank
      end
    end
    
    
    context "find every resource" do
      before(:each) { @customers = Customer.find :all }
      
      it "should return an array" do
        @customers.class.should == Array
      end
      
      it "should include customer number one" do
        @customers.should be_include(Customer.find(1))
      end
      
      it "should have size of one" do
        @customers.size.should == 1
      end
    end
    
    
    context "find every resource with a param-filter" do
      before(:each) do
        Dupe.create Customer, :name => 'Marco', :state => 'inactive'
        Get %r{\/customers\.xml\?state=(active|inactive)} do |state|
          if state == 'active'
            Dupe.find(:"Customers") {|customer| customer.state == 'active'}
          elsif state == 'inactive'
            Dupe.find(:"Customers") {|customer| customer.state == 'inactive'}
          else
            Dupe.find(:"Customers")
          end
        end
      end
      
      it "should find all active customers" do
        active_customers = Customer.find :all, :params => {:state => 'active'}
        active_customers.size.should == 1
        active_customers.should be_include(Customer.find(1))
      end
      
      it "should find all inactive customers" do
        inactive_customers = Customer.find :all, :params => {:state => 'inactive'}
        inactive_customers.size.should == 1
        inactive_customers.should be_include(Customer.find(2))
      end
      
      it "should find all customers without a filter" do
        customers = Customer.find :all, :params => {}
        customers.size.should == 2
        customers.should == Customer.find(:all)
      end
    end
  end
end