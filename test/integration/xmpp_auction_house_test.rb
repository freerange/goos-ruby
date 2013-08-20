require "test_helper"

java_import java.util.concurrent.CountDownLatch
java_import java.util.concurrent.TimeUnit

require "xmpp_auction_house"
require "announcer"
require "end-to-end/fake_auction_server"
require "end-to-end/application_runner"

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
    auction = @auction_house.auction_for(@auction_server.item_id)
    auction.add_auction_event_listener(auction_closed_listener(auction_was_closed))
    auction.join
    @auction_server.has_received_join_request_from(ApplicationRunner::SNIPER_XMPP_ID)
    @auction_server.announce_closed
    assert auction_was_closed.await(2, java.util.concurrent.TimeUnit::SECONDS), "should have been closed"
  end

  private

  def auction_closed_listener(auction_was_closed)
    Class.new do
      def initialize(auction_was_closed)
        @auction_was_closed = auction_was_closed
      end

      def auction_closed
        @auction_was_closed.countDown
      end

      def current_price(price, increment, price_source)
        # not implemented
      end
    end.new(auction_was_closed)
  end
end

