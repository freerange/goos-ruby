require "price_source"

class AuctionSniper
  def initialize(auction, sniper_listener)
    @auction, @sniper_listener = auction, sniper_listener
    @is_winning = false
  end

  def current_price(price, increment, price_source)
    if @is_winning = (price_source == PriceSource::FROM_SNIPER)
      @sniper_listener.sniper_winning
    else
      @auction.bid(price + increment)
      @sniper_listener.sniper_bidding
    end
  end

  def auction_closed
    if @is_winning
      @sniper_listener.sniper_won
    else
      @sniper_listener.sniper_lost
    end
  end
end
