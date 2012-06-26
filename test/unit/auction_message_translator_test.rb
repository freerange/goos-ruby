require "test_helper"

require "auction_message_translator"
require "price_source"

java_import org.jivesoftware.smack.packet.Message

describe AuctionMessageTranslator do

  SNIPER_ID = "sniper id"
  UNUSED_CHAT = nil

  before do
    @listener = mock("AuctionEventListener")
    @translator = AuctionMessageTranslator.new(SNIPER_ID, @listener)
  end

  it "notifies auction closed when close message received" do
    @listener.expects(:auction_closed)

    message = Message.new
    message.setBody("SQLVersion: 1.1; Event: CLOSE;")
    @translator.processMessage(UNUSED_CHAT, message)
  end

  it "notifies bid details when current price message received from other bidder" do
    @listener.expects(:current_price).with(192, 7, PriceSource::FROM_OTHER_BIDDER)

    message = Message.new
    message.setBody("SQLVersion: 1.1; Event: PRICE; CurrentPrice: 192; Increment: 7; Bidder: Someone else;" )
    @translator.processMessage(UNUSED_CHAT, message)
  end

  it "notifies bid details when current price message received from sniper" do
    @listener.expects(:current_price).with(234, 5, PriceSource::FROM_SNIPER)

    message = Message.new
    message.setBody("SQLVersion: 1.1; Event: PRICE; CurrentPrice: 234; Increment: 5; Bidder: #{SNIPER_ID};" )
    @translator.processMessage(UNUSED_CHAT, message)
  end
end
