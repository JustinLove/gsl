Dir.glob(File.join(File.dirname(__FILE__), 'gsl', '*.rb')).
  each {|f| require f}
