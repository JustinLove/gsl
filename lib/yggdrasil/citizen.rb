require File.join(File.expand_path(File.dirname(__FILE__)), 'passport')

module Yggdrasil
  module Citizen
    module Object
      attr_reader :world
      
      def initialize
        super
        @w = Passport.new(self)
      end
      
      def to_s
        "Citizen #{object_id} of #{@world}"
      end
      alias_method :citizen_s, :to_s
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
        self.__send__ :define_method, "#{var}=" do |v|
          @w[var] = v
        end
      end
      
      def ygg_reader(var)
        self.__send__ :define_method, var do
          @w[var]
        end
      end
      
      def ygg_accessor(var)
        ygg_reader(var)
        ygg_writer(var)
      end
      
      def ygg_property(var)
        self.__send__ :define_method, var do |*parameters|
          v, *ignored = *parameters
          if (v)
            @w[var] = v
          else
            @w[var]
          end
        end
      end
    end
  end
end