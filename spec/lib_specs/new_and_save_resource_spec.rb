require 'spec_helper'

module Ns
  class Ns::Address < ActiveResource::Base
    self.site = ''
  end
end

describe Ns::Address do

  context "creating and saving a namespaced resource" do
    it 'should allow to first instantiate and then save a resource' do
      Dupe.define :"Ns::Address"
      Ns::Address.find(:all).size.should be(0)
      new_address = Ns::Address.new
      new_address.save
      new_address.id.should_not be_nil
      Ns::Address.find(:all).size.should be(1)
    end
  end
  
end
