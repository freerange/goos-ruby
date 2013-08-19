class Announcer
  class Proxy
    def initialize(listeners)
      @listeners = listeners
    end

    def method_missing(method, *args)
      @listeners.each { |l| l.send(method, *args) }
    end
  end

  def initialize
    @listeners = []
  end

  def add_listener(listener)
    @listeners << listener
  end

  def announce
    Proxy.new(@listeners)
  end
end