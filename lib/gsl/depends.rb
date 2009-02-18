module GSL
  def self.depends_on(args)
    args.each do |file|
      require File.join(File.expand_path(File.dirname(__FILE__)), file)
    end
  end
end
