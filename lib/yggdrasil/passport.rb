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
      @oid + key.to_s
    end
    
    def [](k)
      @world[@oid + k.to_s]
    end
    
    def []=(k, v)
      @world[@oid + k.to_s] = v
    end
    
    def update(k, default = nil, &proc)
      @world.state.update(@oid + k.to_s, default, &proc)
    end
  end
end