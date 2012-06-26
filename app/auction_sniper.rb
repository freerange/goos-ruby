require "price_source"

class AuctionSniper
  def initialize(auction, sniper_listener)
    @auction, @sniper_listener = auction, sniper_listener
  end

  def current_price(price, increment, price_source)
    @auction.bid(price + increment)
    @sniper_listener.sniper_bidding
  end

  def auction_closed
    @sniper_listener.sniper_lost
  end
end
