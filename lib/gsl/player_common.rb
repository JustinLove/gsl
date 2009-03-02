require File.join(File.expand_path(File.dirname(__FILE__)), 'depends')
GSL::depends_on %w{action}

module Yggdrasil
  class State
    def difference
      @d.keys.size
    end
  end
end

module GSL
  class Player
    module Common
      def choose(from, &doing)
        best = best_rated(choose_from_what(from), &doing).switch
        #note "choose #{best.what} from #{from}"
        return best.what
      end
      
      def consider(from, &doing)
        best_rated(choose_from_what(from), &doing).what
      end

      def choose_from_what(from)
        case from.class.to_s.to_sym
        when :Array:
          from
        when :Hash:
          from.values
        when :Range:
          from.to_a
        when :Fixnum
          (0..from).to_a
        when :Symbol:
          __send__(from)
        else
          if (from.kind_of? Resource)
            from
          else
            Language.error "can't choose from a #{from.class}"
          end
        end
      end
      
      def best_rated(from, &doing)
        choices = from.map {|c|
          rate(c, &doing)
        }.sort_by {|r| r.rating}
        best = choices.last || Future::Nil.new
        unless (best.nil? || best.legal?)
          Game.illegal(:NoLegalOptions, choices.map{|c| c.why}.join(', '))
        end
        best
      end
      
      def rate(what, why = 'rates', &doing)
        s = Future.new(self, what, why, &doing)
        s.rating = rate_state(s.state)
        s
      end

      def rate_state(state)
        if (state && state[:legal]) then
          if (@game.respond_to? :score)
            @world.eval(state) {@game.score; score}
          else
            state.difference + (1..10).random
          end
        else
          -Infinity
        end
      end
      
      def execute(what)
        if (what.to_proc)
          what.to_proc.call_on(self)
        else
          Language.error "not executable"
        end
      end
      
      def action(name = "?", &proc)
        Action.new(name, &proc)
      end
      
      def no_action
        NoAction.new
      end
    end
  end
end
