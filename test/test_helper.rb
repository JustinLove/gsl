def libs(args)
  args.each do |file|
    require File.join(File.dirname(__FILE__), '..', 'lib', file)
  end
end

def tests(args)
  args.each do |file|
    require File.join(File.dirname(__FILE__), file)
  end
end