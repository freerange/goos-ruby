require "test_helper"

require "auction_message_translator"
require "price_source"

java_import org.jivesoftware.smack.packet.Message

describe AuctionMessageTranslator do

  SNIPER_ID = "sniper id"
  UNUSED_CHAT = nil

  before do
    @listener = mock("AuctionEventListener")
    @failure_reporter = mock("XMPPFailureReporter")
    @translator = AuctionMessageTranslator.new(SNIPER_ID, @listener, @failure_reporter)
  end

  it "notifies auction closed when close message received" do
    @listener.expects(:auction_closed)

    body = "SQLVersion: 1.1; Event: CLOSE;"
    @translator.processMessage(UNUSED_CHAT, message(body))
  end

  it "notifies bid details when current price message received from other bidder" do
    @listener.expects(:current_price).with(192, 7, PriceSource::FROM_OTHER_BIDDER)

    body = "SQLVersion: 1.1; Event: PRICE; CurrentPrice: 192; Increment: 7; Bidder: Someone else;"
    @translator.processMessage(UNUSED_CHAT, message(body))
  end

  it "notifies bid details when current price message received from sniper" do
    @listener.expects(:current_price).with(234, 5, PriceSource::FROM_SNIPER)

    body = "SQLVersion: 1.1; Event: PRICE; CurrentPrice: 234; Increment: 5; Bidder: #{SNIPER_ID};"
    @translator.processMessage(UNUSED_CHAT, message(body))
  end

  it "notifies auction failed when bad message received" do
    bad_message = "a bad message"
    expect_failure_with_message(bad_message)
    @translator.processMessage(UNUSED_CHAT, message(bad_message))
  end

  it "notifies auction failed when event type missing" do
    body_without_type = "SOLVersion: 1.1; CurrentPrice: 234; Increment: 5; Bidder: #{SNIPER_ID};"
    expect_failure_with_message(body_without_type)
    @translator.processMessage(UNUSED_CHAT, message(body_without_type))
  end

  private

  def message(body)
    message = Message.new
    message.setBody(body)
    return message
  end

  def expect_failure_with_message(bad_message)
    @listener.expects(:auction_failed).once
    @failure_reporter.expects(:cannot_translate_message).with(SNIPER_ID, bad_message, kind_of(StandardError)).once
  end
end
