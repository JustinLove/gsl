%w{world citizen}.each do |file|
  require File.join(File.expand_path(File.dirname(__FILE__)), 'yggdrasil', file)
end
