module Tattler
  @@bell = nil
  def self.bell
    @@bell
  end

  def initialize
    super()
    @@bell = self
  end
end

shared_examples_for "well behaved objects" do
  it "looks nice" do
    s = @object.to_s 
    s.should be_kind_of(String)
    s.length.should be_between(1,80)
    s.should_not match(/#<.*>/)
  end
  
  it "initialize calls super" do
    Tattler.bell.should == @object
  end
end