require "test_helper"

require "sniper_snapshot"
require "sniper_state"

describe SniperSnapshot do
  before do
    @snapshot = SniperSnapshot.new(item_id: "item-id", last_price: 123, last_bid: 456, state: SniperState::WINNING)
  end

  it "is equal to snapshot with same attributes" do
    assert_equal @snapshot, SniperSnapshot.new(item_id: "item-id", last_price: 123, last_bid: 456, state: SniperState::WINNING)
  end

  it "is not equal to snapshot with different item_id" do
    refute_equal @snapshot, SniperSnapshot.new(item_id: "another-item-id", last_price: 123, last_bid: 456, state: SniperState::WINNING)
  end

  it "is not equal to snapshot with different last_price" do
    refute_equal @snapshot, SniperSnapshot.new(item_id: "item-id", last_price: 999, last_bid: 456, state: SniperState::WINNING)
  end

  it "is not equal to snapshot with different last_bid" do
    refute_equal @snapshot, SniperSnapshot.new(item_id: "item-id", last_price: 123, last_bid: 999, state: SniperState::WINNING)
  end

  it "is not equal to snapshot with different state" do
    refute_equal @snapshot, SniperSnapshot.new(item_id: "item-id", last_price: 123, last_bid: 456, state: SniperState::JOINING)
  end
end
