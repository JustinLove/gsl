module GSL
  class Player
    module Common
      def choose(from, &doing)
        best = best_rated(choose_from_what(from), &doing)
        if (best)
          #note "choose #{best.to_s} from #{from}"
          return execute best, &doing
        else
          return best
        end
      end

      def choose_from_what(from)
        case from.class.to_s.to_sym
        when :Array:
          from
        when :Hash:
          from.values
        when :Symbol:
          __send__(from)
        else
          if (from.kind_of? Resource)
            from
          else
            throw "can't choose from a #{from.class}"
          end
        end
      end
      
      def best_rated(from, &doing)
        # concat: operate on a copy so changes don't mess us up
        [].concat(from.concat []).sort_by {|c| -rate(c, 'best', &doing)}.first
      end
      
      def judge(action)
        if rate(action, 'judges') > 0 then :good else :bad end
      end
    
      def rate(action, why = 'rates', &doing)
        raise if !action
        if (action.respond_to? :in)
          action.in.without(action) {rate_action action, why, &doing}
        else
          rate_action(action, why, &doing)
        end
      end

      def rate_action(action, why = 'rates', &doing)
        good = what_if("#{why} #{action.to_s}") {execute action, &doing}
        if good[:legal] then 1 else 0 end
      end

      def legal?(action)
        what_if("checks #{action.to_s}") {execute action}[:legal]
      end
      
      def what_if(on = '?', &proc)
        Speculate.new(self, on).branch(&proc) #.tap {|v| p v}
      end

      def execute(*args, &proc)
        if proc
          instance_exec(*args, &proc)
        elsif (args && args.first.respond_to?(:to_proc))
          action = args.shift
          instance_exec(*args, &(action.to_proc))
        else
          raise "nothing executable"
        end
      end
    end
  end
end
