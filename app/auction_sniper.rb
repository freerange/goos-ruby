require "price_source"

class AuctionSniper
  def initialize(item_id, auction, sniper_listener)
    @item_id, @auction, @sniper_listener = item_id, auction, sniper_listener
    @is_winning = false
  end

  def current_price(price, increment, price_source)
    if @is_winning = (price_source == PriceSource::FROM_SNIPER)
      @sniper_listener.sniper_winning
    else
      bid = price + increment
      @auction.bid(bid)
      @sniper_listener.sniper_bidding(SniperState.new(@item_id, price, bid))
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
