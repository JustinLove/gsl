module Yggdrasil
  class Passport
    attr_accessor :world
    
    def initialize(owner)
      @world = owner.world
      super()
      @owner = owner
      @oid = owner.object_id.to_s
    end
    
    def to_s
      "Passport #{@oid} for #{@owner}"
    end
    
    def inspect
      "Passport #{@oid} for #{@owner}"
    end
    
    def rune(key)
      key.to_s + @oid
    end
    
    def [](k)
      @world[k.to_s + @oid]
    end
    
    def []=(k, v)
      @world[k.to_s + @oid] = v
    end
    
    def update(k, default = nil, &proc)
      @world.state.update(k.to_s + @oid, default, &proc)
    end
  end
end