$:.unshift File.dirname(__FILE__)

require 'spec_helper'

describe Echonest do
  it "should return an instance of Echonest::Api" do
    Echonest('XXXXXXXX').should be_an_instance_of(Echonest::Api)
  end
end
