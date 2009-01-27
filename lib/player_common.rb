module GSL
  class Player
    module Common
      def choose(from, &doing)
        best = best_rated(choose_from_what(from), &doing)
        if (best)
          #note "choose #{best.why} from #{from}"
          return execute best.what, &doing
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
        from.map {|c|
          rate(c, 'best', &doing)
        }.sort_by {|r| -r.rating}.first
      end
      
      def judge(action)
        if rate(action, 'judges').rating > 0 then :good else :bad end
      end
    
      def rate(action, why = 'rates', &doing)
        s = Speculation.new(self, action, why, &doing)
        s.rating = rate_state(s.state)
        s
      end

      def rate_state(state)
        if (state[:legal]) then 1 else 0 end
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
