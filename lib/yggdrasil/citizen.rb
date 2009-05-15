require File.join(File.expand_path(File.dirname(__FILE__)), 'passport')

module Yggdrasil
  module Citizen
    module Object
      attr_reader :world
      
      def world=(v)
        @w.world = @world = v
      end
      private :world=
      
      def initialize
        super
        @w = Passport.new(self)
      end
      
      def to_s
        "Citizen #{object_id} of #{@world}"
      end
      alias_method :citizen_s, :to_s
      
      def inspect
        "Citizen #{object_id} of #{@world}"
      end
    end

    module SuperClass
      def included(base)
        #puts "Citizen included #{base.name}"
        base.extend SuperClass
      end

      def extended(base)
        #puts "Citizen extend #{base.name}"
        base.__send__ :include, Citizen::Object
      end
    end

    module Class
      extend SuperClass
      
      def ygg_writer(var)
        self.class_eval "def #{var}=(v); @w[:#{var}] = v; end"
      end
      
      def ygg_reader(var)
        self.class_eval "def #{var}; @w[:#{var}]; end"
      end
      
      def ygg_accessor(var)
        ygg_reader(var)
        ygg_writer(var)
      end
      
      def ygg_property(var)
        self.class_eval <<-PROP
          def #{var}(v = nil)
            if (v)
              @w[:#{var}] = v
            else
              @w[:#{var}]
            end
          end
        PROP
      end
    end
  end
end