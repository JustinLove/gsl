module Tattler
  @@callers = []
  def self.callers
    @@callers
  end

  def initialize
    super()
    @@callers << self
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
    Tattler.callers.should include(@object)
  end
end