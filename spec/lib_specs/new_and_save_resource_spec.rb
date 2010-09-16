require 'spec_helper'

module Ns
  class Ns::Address < ActiveResource::Base
    self.site = ''
  end
end

describe Ns::Address do
  context "creating and saving a namespaced resource" do
    it 'should allow to first instantiate and then save a resource' do
      Dupe.reset
      Dupe.define :"Ns::Address"
      Ns::Address.find(:all).size.should be(0)
      new_address = Ns::Address.new
      new_address.save
      new_address.id.should_not be_nil
      Ns::Address.find(:all).size.should be(1)
    end
  end
  
  
  context "create a mock of the address" do
    before(:each) do
      Dupe.reset
      Dupe.create :"Ns::Address", :id => 100, :name => 'test'
    end
    
    it "should find address with id" do
      Ns::Address.find(100).should_not be_blank
    end
  end
  
end
