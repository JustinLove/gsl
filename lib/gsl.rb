%w{lib/misc
   lib/classvar
   lib/random
   lib/prototype
   lib/properties
   
   lib/resource_user
   lib/game
   lib/component
   lib/resource
   lib/value_resource
   lib/set_resource
   lib/player
   lib/speculate}.each do |lib|
     require File.join(File.dirname(__FILE__), '../', lib)
   end

Game.new(ARGV.shift)
