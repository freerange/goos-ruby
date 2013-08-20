require "test_helper"

require "sniper_state"

describe SniperState do
  it "is won when auction closes while winning" do
    assert_equal SniperState::LOST, SniperState::JOINING.when_auction_closed
    assert_equal SniperState::LOST, SniperState::BIDDING.when_auction_closed
    assert_equal SniperState::LOST, SniperState::LOSING.when_auction_closed
    assert_equal SniperState::WON, SniperState::WINNING.when_auction_closed
  end

  it "raises exception if auction closes when won" do
    assert_raises(RuntimeError) { SniperState::WON.when_auction_closed }
  end

  it "raises exception if auction closes when lost" do
    assert_raises(RuntimeError) { SniperState::LOST.when_auction_closed }
  end
end
