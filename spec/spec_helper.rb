def libs(args)
  args.each do |file|
    require File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', 'gsl', file))
  end
end

def tests(args)
  args.each do |file|
    require File.expand_path(File.join(File.dirname(__FILE__), file))
  end
end

def file(arg)
  File.expand_path(File.join(File.dirname(__FILE__), '..', arg))
end

tests 'shared_spec'
