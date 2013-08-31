require "test_helper"

require "xmpp_auction_house"
require "announcer"
require "item"
require "end-to-end/fake_auction_server"
require "end-to-end/application_runner"
require "countdownlatch"

describe XMPPAuctionHouse do
  before do
    @auction_server = FakeAuctionServer.new("item-54321")
    @auction_server.start_selling_item
    @auction_house = XMPPAuctionHouse.connect(FakeAuctionServer::XMPP_HOSTNAME, ApplicationRunner::SNIPER_ID, ApplicationRunner::SNIPER_PASSWORD)
  end

  after do
    @auction_house.disconnect
    @auction_server.stop
  end

  it "receives events from auction server after joining" do
    auction_was_closed = CountDownLatch.new(1)
    auction = @auction_house.auction_for(Item.new(@auction_server.item_id, 567))
    auction.add_auction_event_listener(auction_closed_listener(auction_was_closed))
    auction.join
    @auction_server.has_received_join_request_from(ApplicationRunner::SNIPER_XMPP_ID)
    @auction_server.announce_closed
    assert auction_was_closed.wait(2), "should have been closed"
  end

  private

  def auction_closed_listener(auction_was_closed)
    Class.new do
      def initialize(auction_was_closed)
        @auction_was_closed = auction_was_closed
      end

      def auction_closed
        @auction_was_closed.countdown!
      end

      def current_price(price, increment, price_source)
        # not implemented
      end
    end.new(auction_was_closed)
  end
end

