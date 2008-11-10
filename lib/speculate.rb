class Speculate
  include Prototype
  include Player::Common
  
  def speculator; @player; end
  
  def self.forward(what, to = nil)
    define_method what do |*args, &proc|
      @player.__send__ to || what, *args, &proc
    end
  end
  
  def initialize(player, on = '?')
    @player = player
    @on = on
  end
  
  def d(s)
    #puts "#{'*' * @@level} #{@player} #{@on}: " + s
  end
  
  @@level = 0
  def go(&proc)
    begin
      @@level += 1
      d 'block ' + proc.inspect
      instance_eval &proc
    rescue InsufficientResources, FailedPrecondition => e
      d e.inspect
      return Passed
    rescue Exception => e
      raise e
    else
      d 'succeeded'
      return Acted
    ensure
      @@level -= 1
    end
  end
  
  def method_missing(method, *args, &proc)
    if @player.has_resource? method
      d "has #{method}"
      return @player.__send__ method, *args, &proc
    elsif @player.respond_to? method
      d 'skipping ' + method.to_s
    else
      d "punts #{method}"
      super
    end
  end

  forward :during
  forward :only_during
  forward :must_have
  forward :must_gain, :if_gain
  forward :must_lose, :if_lose
  forward :gain, :if_gain
  forward :lose, :if_lose
  forward :pay, :if_lose
end
