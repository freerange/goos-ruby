require "test_helper"

require "auction_message_translator"

java_import org.jivesoftware.smack.packet.Message

describe AuctionMessageTranslator do

  UNUSED_CHAT = nil

  before do
    @listener = mock("AuctionEventListener")
    @translator = AuctionMessageTranslator.new(@listener)
  end

  it "notifies auction closed when close message received" do
    @listener.expects(:auction_closed)

    message = Message.new
    message.setBody("SQLVersion: 1.1; Event: CLOSE;")
    @translator.processMessage(UNUSED_CHAT, message)
  end

  it "notifies bid details when current price message received" do
    @listener.expects(:current_price).with(192, 7)

    message = Message.new
    message.setBody("SQLVersion: 1.1; Event: PRICE; CurrentPrice: 192; Increment: 7; Bidder: Someone else;" )
    @translator.processMessage(UNUSED_CHAT, message)
  end
end
