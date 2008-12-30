require File.join(File.dirname(__FILE__), '../lib/gsl')

describe "ClassVars" do
  
  describe "on Object" do
    before do
      @obj = Object.new
    end

    it "should have cv" do
      @obj.should be_respond_to(:cv)
    end
  end
  
  describe "on Class" do
    before do
      @class = Class.new
    end
  
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
      before do
        @class.psuedo_class_var :billy
        @inst = @class.new
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
end
