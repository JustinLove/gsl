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
    
    def id_card(key)
      @oid + key.to_s
    end
    
    def [](k)
      @world[id_card(k)]
    end
    
    def []=(k, v)
      @world[id_card(k)] = v
    end
    
    def update(k, default = nil, &proc)
      @world.state.update(id_card(k), default, &proc)
    end
  end
end