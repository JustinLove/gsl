require 'gsl/lib/gsl.rb'

describe "ClassVars" do
  
  describe "on Object" do
    before do
      @obj = Object.new
    end

    it "should have cv" do
      @obj.respond_to? :cv
    end
  end
  
  describe "on Class" do
    before do
      @class = Class.new
    end
  
    it "should have cv" do
      @class.respond_to? :cv
    end
    
    it "should have psuedo_class_var" do
      @class.respond_to? :psuedo_class_var
    end
  end
end
