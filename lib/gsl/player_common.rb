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
        when :Array
          from
        when :Hash
          from.values
        when :Range
          from.to_a
        when :Fixnum
          (0..from).to_a
        when :Symbol
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
          @world.eval(state) {relative_fitness + state.difference * 0.01} #.tap{|x| puts "#{state}: #{x}"}
        else
          -Infinity
        end
      end
      
      def relative_fitness
        @game.simple_fitness
        fits = players.map {|p| p.absolute_fitness}
        best = fits.max
        average = fits.inject(0) {|sum,x| sum + x} / fits.length
        trail = absolute_fitness - best
        pack = absolute_fitness - average
        trail + pack
      end
      
      def execute(what)
        if (what.to_proc)
          what.to_proc.call_on(self)
        else
          Language.error "not executable"
        end
      end
    end
  end
end
