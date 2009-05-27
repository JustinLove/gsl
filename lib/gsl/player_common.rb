require File.join(File.expand_path(File.dirname(__FILE__)), 'depends')
GSL::depends_on %w{action plan}

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
        best = choose_best(from, &doing).switch
        #note "choose #{best.what} from #{from}"
        return best.what
      end
      
      def take(from, &doing)
        best = choose_best(from, &doing).switch
        #note "take #{best.what} from #{from}"
        must_lose [best.what], from if best.legal?
        return best.what
      end

      def consider(from, &doing)
        choose_best(from, &doing).what
      end
      
      def choose_best(from, &doing)
        list_of_choices(from, &doing).best
      end
      
      def list_of_choices(from, &doing)
        Plan.new(self, from, &doing)
      end

      def rate_state(state)
        if (state) then
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
