require "price_source"
require "sniper_snapshot"
require "announcer"

class AuctionSniper
  attr_reader :snapshot

  def initialize(item_id, auction)
    @item_id, @auction = item_id, auction
    @is_winning = false
    @snapshot = SniperSnapshot.joining(item_id)
    @listeners = Announcer.new
  end

  def add_sniper_listener(sniper_listener)
    @listeners.add_listener(sniper_listener)
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
    @listeners.announce.sniper_state_changed(@snapshot)
  end
end
