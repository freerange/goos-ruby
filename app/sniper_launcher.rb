java_import javax.swing.SwingUtilities

require "sniper_snapshot"
require "auction_sniper"

class SniperLauncher
  class SwingThreadSniperListener
    def initialize(snipers)
      @snipers = snipers
    end

    def sniper_state_changed(snapshot)
      SwingUtilities.invokeLater do
        @snipers.sniper_state_changed(snapshot)
      end
    end
  end

  def initialize(auction_house, snipers)
    @auction_house, @snipers = auction_house, snipers
    @not_to_be_garbage_collected = []
  end

  def join_auction(item_id)
    @snipers.add_sniper(SniperSnapshot.joining(item_id))
    auction = @auction_house.auction_for(item_id)
    @not_to_be_garbage_collected << auction
    auction.add_auction_event_listener(AuctionSniper.new(item_id, auction, SwingThreadSniperListener.new(@snipers)))
    auction.join
  end
end