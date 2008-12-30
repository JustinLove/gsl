require File.join(File.dirname(__FILE__), '../lib/classvar')

describe Object do
  before :all do
    @obj = Object.new
  end

  it "should not have cv" do
    @obj.should_not be_respond_to(:cv)
  end
end

describe Class do
  before :all do
    @class = Class.new
  end

  it "should not have cv" do
    @class.should_not be_respond_to(:cv)
  end
  
  it "should not have psuedo_class_var" do
    @class.should_not be_respond_to(:psuedo_class_var)
  end
end

describe "extended classes", :shared => true do
  it "should have cv" do
    @class.should be_respond_to(:cv)
  end
  
  it "should have psuedo_class_var" do
    @class.should be_respond_to(:psuedo_class_var)
  end
  
  it "should create variables" do
    @class.psuedo_class_var :barney
    @class.cv.should be_respond_to(:barney)
  end
  
  it "should read and assign" do
    @class.psuedo_class_var :fred
    lambda {@class.cv.fred = 1}.should_not raise_error
    @class.cv.fred.should == 1
  end
  
  describe "instance" do
    before :all do
      @class.psuedo_class_var :billy
      @inst = @class.new
    end

    it "should have cv" do
      @inst.should be_respond_to(:cv)
    end
    
    it "should have the var" do
      @inst.cv.should be_respond_to(:billy)
    end
    
    it "should share values" do
      @class.cv.billy = 1
      @inst.cv.billy.should == 1
    end
    
    it "should share between instances" do
      @inst.cv.billy = 2
      @class.new.cv.billy.should == 2
    end
  end
end

describe Class::Vars do
  describe "directly extended" do
    before :all do
      @class = class Rat; self; end
      @class.extend Class::Vars
    end
    
    it_should_behave_like "extended classes"
  end


  describe "indirectly extended" do
    before :all do
      @mod = module Needle; include Class::Vars; self; end
      @class = class LabRat; extend Needle; self; end
    end
    
    describe "Module" do
      it "should be extendable" do
        @mod.should be_respond_to(:extended)
      end

      it "should be includable" do
        @mod.should be_respond_to(:included)
      end
    end
    
    it_should_behave_like "extended classes"
  end
end
