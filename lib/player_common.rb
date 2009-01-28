require File.join(File.expand_path(File.dirname(__FILE__)), 'depends')
GSL::depends_on %w{action}

module GSL
  class Player
    module Common
      def choose(from, &doing)
        best = best_rated(choose_from_what(from), &doing)
        if (best)
          best.switch_if_legal
          #note "choose #{best.why} from #{from}"
          return best.what
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
          rate(c, &doing)
        }.sort_by {|r| -r.rating}.first
      end
      
      def rate(what, why = 'rates', &doing)
        s = Speculation.new(self, what, why, &doing)
        s.rating = rate_state(s.state)
        s
      end

      def rate_state(state)
        if (state[:legal]) then (1..100).random else 0 end
      end

      def execute(*args, &proc)
        if proc
          instance_exec(*args, &proc)
        elsif (args && args.first.respond_to?(:to_proc))
          what = args.shift # modify args before passing remainder
          instance_exec(*args, &(what.to_proc))
        else
          raise "nothing executable"
        end
      end
      
      def action(name = "?", &proc)
        Action.new(name, &proc)
      end
    end
  end
end
