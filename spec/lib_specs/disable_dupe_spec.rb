require 'spec_helper'

class Something < ActiveResource::Base
  self.site = 'http://localhost'
end

describe Something do
  it 'works as usuall witch mocked responses' do
    Dupe.create Something, :name => 'really nothing'
    Something.find(1).should be_a Something
  end

  it 'ignores mocked resources when disabled' do
    Dupe.disable!
    Dupe.disabled?.should be true
    lambda { Something.find(1) }.should raise_error
  end

  it 'works as usuall again when enabled' do
    Dupe.enable!
    Dupe.create Something, :name => 'really nothing'
    Something.find(1).should be_a Something
  end
end
