require File.join(File.dirname(__FILE__), '..', 'spec_helper')
libs %w{gsl/historian gsl/resource_user}

class GSL::Historian
  include Tattler
end

class User
  include GSL::ResourceUser
  include Yggdrasil::Citizen::Class

  def initialize
    @world = Yggdrasil::World.new
    @world.state.name = "root"
    super
  end
  
  make_resource :cheese
end

describe GSL::Historian do
  before do
    @object = @historian = GSL::Historian.new
    @user = User.new
    @user.set 0, :cheese
  end
  
  it_should_behave_like "well behaved objects"
  
  describe GSL::Historian::Event do  
    before do
      @object = @event = @historian.event
    end
    
    it "records history" do
      @object.record(@user.cheese)
    end
  end
end

