require "test_helper"

require "auction_sniper"
require "price_source"
require "sniper_snapshot"
require "sniper_state"
require "item"

describe AuctionSniper do
  ITEM_ID = "item-id"

  before do
    @auction = mock("Auction")
    @sniper_listener = mock("SniperListener")
    @item = Item.new(ITEM_ID, 1234)
    @sniper = AuctionSniper.new(@item, @auction)
    @sniper.add_sniper_listener(@sniper_listener)
    @sniper_state = states("sniper")
  end

  it "reports lost when auction closes immediately" do
    @sniper_listener.expects(:sniper_state_changed).with(&a_sniper_that_is(SniperState::LOST)).at_least_once
    @sniper.auction_closed
  end

  it "reports lost if auction closes when bidding" do
    @auction.stub_everything
    @sniper_listener.stubs(:sniper_state_changed).with(&a_sniper_that_is(SniperState::BIDDING)).then(@sniper_state.is("bidding"))
    @sniper_listener.expects(:sniper_state_changed).with(&a_sniper_that_is(SniperState::LOST)).at_least_once.when(@sniper_state.is("bidding"))

    @sniper.current_price(123, 45, PriceSource::FROM_OTHER_BIDDER)
    @sniper.auction_closed
  end

  it "reports won if auction closes when winning" do
    @auction.stub_everything
    @sniper_listener.stubs(:sniper_state_changed).with(&a_sniper_that_is(SniperState::WINNING)).then(@sniper_state.is("winning"))
    @sniper_listener.expects(:sniper_state_changed).with(&a_sniper_that_is(SniperState::WON)).at_least_once.when(@sniper_state.is("winning"))

    @sniper.current_price(123, 45, PriceSource::FROM_SNIPER)
    @sniper.auction_closed
  end

  it "bids higher and reports bidding when new price arrives" do
    price = 1001
    increment = 25
    bid = price + increment
    @auction.expects(:bid).with(bid)
    @sniper_listener.expects(:sniper_state_changed).with(SniperSnapshot.new(ITEM_ID, price, bid, SniperState::BIDDING)).at_least_once
    @sniper.current_price(price, increment, PriceSource::FROM_OTHER_BIDDER)
  end

  it "reports is winning when current price comes from sniper" do
    @auction.stub_everything
    @sniper_listener.stubs(:sniper_state_changed).with(&a_sniper_that_is(SniperState::BIDDING)).then(@sniper_state.is("bidding"))
    winning_snapshot = SniperSnapshot.new(ITEM_ID, 135, 135, SniperState::WINNING)
    @sniper_listener.expects(:sniper_state_changed).with(winning_snapshot).at_least_once.when(@sniper_state.is("bidding"))

    @sniper.current_price(123, 12, PriceSource::FROM_OTHER_BIDDER)
    @sniper.current_price(135, 45, PriceSource::FROM_SNIPER)
  end

  private

  def a_sniper_that_is(expected_state)
    lambda { |snapshot| snapshot.state == expected_state }
  end
end
