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
  end
end
