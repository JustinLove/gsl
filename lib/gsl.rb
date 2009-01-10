require File.join(File.expand_path(File.dirname(__FILE__)), 'depends')
GSL::depends_on %w{game}

GSL::Game.new(ARGV.shift) if ARGV.length > 0
