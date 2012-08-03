require "price_source"
require "sniper_snapshot"

class AuctionSniper
  def initialize(item_id, auction, sniper_listener)
    @item_id, @auction, @sniper_listener = item_id, auction, sniper_listener
    @is_winning = false
    @snapshot = SniperSnapshot.joining(item_id)
  end

  def current_price(price, increment, price_source)
    case price_source
    when PriceSource::FROM_SNIPER
      @snapshot = @snapshot.winning(price)
    when PriceSource::FROM_OTHER_BIDDER
      bid = price + increment
      @auction.bid(bid)
      @snapshot = @snapshot.bidding(price, bid)
    end
    notify_change
  end

  def auction_closed
    @snapshot = @snapshot.closed
    notify_change
  end

  private

  def notify_change
    @sniper_listener.sniper_state_changed(@snapshot)
  end
end
