class AuctionSniper
  def initialize(sniper_listener)
    @sniper_listener = sniper_listener
  end

  def auction_closed
    @sniper_listener.sniper_lost
  end
end
