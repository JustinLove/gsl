require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'yggdrasil')

module Yggdrasil
  class State
    include Tracing
    #include Logging
    include ReadCache
  end
end
