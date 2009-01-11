require File.join(File.dirname(__FILE__), 'spec_helper')
libs %w{properties}

class Rat
  extend Properties
  as_property :title
  def report_title
    @title
  end
  as_proc :wiggle
  def report_wiggle
    @wiggle
  end
end

describe Properties do
  before do
    @object = Rat.new
  end
  
  it "sets a proprety" do
    @object.title "Larry"
    @object.report_title.should == "Larry"
  end
  
  it "gets a proprety" do
    @object.title "Larry"
    @object.title.should == "Larry"
  end
  
  it "sets a proc" do
    @object.wiggle do
      "blarg"
    end
    @object.report_wiggle.call.should == "blarg"
  end

  it "runs a proc" do
    @object.wiggle do
      self
    end
    @object.wiggle.should == @object
  end
end