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

  it "bids higher and reports bidding when new price arrives" do
    price = 1001; increment = 25; bid = price + increment
    bidding_snapshot = SniperSnapshot.new(ITEM_ID, price, bid, SniperState::BIDDING)
    @auction.expects(:bid).with(bid)
    @sniper_listener.expects(:sniper_state_changed).with(bidding_snapshot).at_least_once

    @sniper.current_price(price, increment, PriceSource::FROM_OTHER_BIDDER)
  end

  it "does not bid and reports losing if first price is above stop price" do
    price = 1233; increment = 25
    losing_snapshot = SniperSnapshot.new(ITEM_ID, price, 0, SniperState::LOSING)
    @sniper_listener.expects(:sniper_state_changed).with(losing_snapshot).at_least_once

    @sniper.current_price(price, increment, PriceSource::FROM_OTHER_BIDDER)
  end

  it "does not bid and reports losing if subsequent price is above stop price" do
    bid = 123 + 45
    losing_snapshot = SniperSnapshot.new(ITEM_ID, 2345, bid, SniperState::LOSING)
    allowing_sniper_bidding
    @auction.stubs(:bid)
    @sniper_listener.expects(:sniper_state_changed).with(losing_snapshot).at_least_once.when(@sniper_state.is("bidding"))

    @sniper.current_price(123, 45, PriceSource::FROM_OTHER_BIDDER)
    @sniper.current_price(2345, 25, PriceSource::FROM_OTHER_BIDDER)
  end

  it "does not bid and reports losing if price after winning is above stop price" do
    price = 1233; increment = 25
    bid = 123 + 45
    losing_snapshot = SniperSnapshot.new(ITEM_ID, price, bid, SniperState::LOSING)
    allowing_sniper_bidding
    allowing_sniper_winning
    @auction.stubs(:bid)
    @sniper_listener.expects(:sniper_state_changed).with(losing_snapshot).at_least_once.when(@sniper_state.is("winning"))

    @sniper.current_price(123, 45, PriceSource::FROM_OTHER_BIDDER)
    @sniper.current_price(168, 45, PriceSource::FROM_SNIPER)
    @sniper.current_price(price, increment, PriceSource::FROM_OTHER_BIDDER)
  end

  it "continues to be losing once stop price has been reached" do
    states = sequence("sniper states")
    price1 = 1233; price2 = 1258
    losing_snapshot1 = SniperSnapshot.new(ITEM_ID, price1, 0, SniperState::LOSING)
    losing_snapshot2 = SniperSnapshot.new(ITEM_ID, price2, 0, SniperState::LOSING)
    @sniper_listener.expects(:sniper_state_changed).with(losing_snapshot1).at_least_once.in_sequence(states)
    @sniper_listener.expects(:sniper_state_changed).with(losing_snapshot2).at_least_once.in_sequence(states)

    @sniper.current_price(price1, 25, PriceSource::FROM_OTHER_BIDDER)
    @sniper.current_price(price2, 25, PriceSource::FROM_OTHER_BIDDER)
  end

  it "reports lost if auction closes when bidding" do
    @auction.stub_everything
    allowing_sniper_bidding
    @sniper_listener.expects(:sniper_state_changed).with(&a_sniper_that_is(SniperState::LOST)).at_least_once.when(@sniper_state.is("bidding"))

    @sniper.current_price(123, 45, PriceSource::FROM_OTHER_BIDDER)
    @sniper.auction_closed
  end

  it "reports lost if auction closes when losing" do
    allowing_sniper_losing
    lost_snapshot = SniperSnapshot.new(ITEM_ID, 1230, 0, SniperState::LOST)
    @sniper_listener.expects(:sniper_state_changed).with(lost_snapshot).at_least_once.when(@sniper_state.is("losing"))

    @sniper.current_price(1230, 456, PriceSource::FROM_OTHER_BIDDER)
    @sniper.auction_closed
  end

  it "reports is winning when current price comes from sniper" do
    @auction.stub_everything
    allowing_sniper_bidding
    winning_snapshot = SniperSnapshot.new(ITEM_ID, 135, 135, SniperState::WINNING)
    @sniper_listener.expects(:sniper_state_changed).with(winning_snapshot).at_least_once.when(@sniper_state.is("bidding"))

    @sniper.current_price(123, 12, PriceSource::FROM_OTHER_BIDDER)
    @sniper.current_price(135, 45, PriceSource::FROM_SNIPER)
  end

  it "reports won if auction closes when winning" do
    @auction.stub_everything
    allowing_sniper_winning
    @sniper_listener.expects(:sniper_state_changed).with(&a_sniper_that_is(SniperState::WON)).at_least_once.when(@sniper_state.is("winning"))

    @sniper.current_price(123, 45, PriceSource::FROM_SNIPER)
    @sniper.auction_closed
  end

  private

  def allowing_sniper_bidding
    allow_sniper_state_change(SniperState::BIDDING, "bidding")
  end

  def allowing_sniper_losing
    allow_sniper_state_change(SniperState::LOSING, "losing")
  end

  def allowing_sniper_winning
    allow_sniper_state_change(SniperState::WINNING, "winning")
  end

  def allow_sniper_state_change(new_state, old_state)
    @sniper_listener.stubs(:sniper_state_changed).with(&a_sniper_that_is(new_state)).then(@sniper_state.is(old_state))
  end

  def a_sniper_that_is(expected_state)
    lambda { |snapshot| snapshot.state == expected_state }
  end
end
