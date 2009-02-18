module Prototype
  def method_missing(which, *args, &block)
    puts "missing #{self.class}.#{which} #{args.inspect} {#{block.inspect}}"
  end
end
