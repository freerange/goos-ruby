require "test_helper"

java_import java.util.concurrent.CountDownLatch
java_import java.util.concurrent.TimeUnit

require "main"
require "xmpp_auction"
require "announcer"
require "end-to-end/fake_auction_server"
require "end-to-end/application_runner"

describe XMPPAuction do
  before do
    @auction_server = FakeAuctionServer.new("item-54321")
    @connection = Main.connection(FakeAuctionServer::XMPP_HOSTNAME, ApplicationRunner::SNIPER_ID, ApplicationRunner::SNIPER_PASSWORD)
  end

  it "receives events from auction server after joining" do
    @auction_server.start_selling_item
    auction_was_closed = CountDownLatch.new(1)
    auction = XMPPAuction.new(@connection, @auction_server.item_id)
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

