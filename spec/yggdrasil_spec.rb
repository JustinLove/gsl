Dir.glob(File.join(File.dirname(__FILE__), 'yggdrasil', '*.rb')).
  each {|f| require f}
