require File.join(File.expand_path(File.dirname(__FILE__)), 'depends')
GSL::depends_on %w{game}

[GSL].each {|constant| include constant}

Game.new(ARGV.shift) if ARGV.length > 0
