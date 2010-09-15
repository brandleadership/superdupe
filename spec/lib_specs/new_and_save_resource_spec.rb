require 'spec_helper'

module Ns
  class Ns::Company < ActiveResource::Base
    self.site = ''
  end
end

describe Ns::Company do

  context "creating and saving a namespaced resource" do
    it 'should allow to first instantiate and then save a resource' do
      Dupe.define :"Ns::Company"
      Ns::Company.find(:all).size.should be(0)
      new_customer = Ns::Company.new
      new_customer.save
      new_customer.id.should_not be_nil
      Ns::Company.find(:all).size.should be(1)
    end
  end
  
end
