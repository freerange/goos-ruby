require "announcer"

class SniperPortfolio
  def initialize
    @snipers = []
    @announcer = Announcer.new
  end

  def add_sniper(sniper)
    @snipers << sniper
    @announcer.announce.sniper_added(sniper)
  end

  def add_portfolio_listener(listener)
    @announcer.add_listener(listener)
  end
end
