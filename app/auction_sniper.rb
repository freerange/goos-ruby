require "price_source"
require "sniper_snapshot"

class AuctionSniper
  def initialize(item_id, auction, sniper_listener)
    @item_id, @auction, @sniper_listener = item_id, auction, sniper_listener
    @is_winning = false
    @snapshot = SniperSnapshot.joining(item_id)
  end

  def current_price(price, increment, price_source)
    if @is_winning = (price_source == PriceSource::FROM_SNIPER)
      @snapshot = @snapshot.winning(price)
    else
      bid = price + increment
      @auction.bid(bid)
      @snapshot = @snapshot.bidding(price, bid)
    end
    @sniper_listener.sniper_state_changed(@snapshot)
  end

  def auction_closed
    if @is_winning
      @sniper_listener.sniper_won
    else
      @sniper_listener.sniper_lost
    end
  end
end
