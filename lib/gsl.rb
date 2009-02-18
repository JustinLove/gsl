require File.join(File.expand_path(File.dirname(__FILE__)), 'gsl/game')

GSL::Game.new(ARGV.shift) if ARGV.length > 0
