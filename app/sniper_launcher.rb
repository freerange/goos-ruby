require "sniper_snapshot"
require "auction_sniper"

class SniperLauncher
  def initialize(auction_house, collector)
    @auction_house, @collector = auction_house, collector
  end

  def join_auction(item_id)
    auction = @auction_house.auction_for(item_id)
    sniper = AuctionSniper.new(item_id, auction)
    auction.add_auction_event_listener(sniper)
    @collector.add_sniper(sniper)
    auction.join
  end
end