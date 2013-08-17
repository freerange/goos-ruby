require "test_helper"

require "ui/column"
require "sniper_snapshot"

describe Column do
  it "restrieves values from a sniper snapshot" do
    snapshot = SniperSnapshot.new("item", 123, 34, SniperState::BIDDING)
    assert_equal "item", Column::ITEM_IDENTIFIER.value_in(snapshot)
    assert_equal 123, Column::LAST_PRICE.value_in(snapshot)
    assert_equal 34, Column::LAST_BID.value_in(snapshot)
    assert_equal "bidding", Column::SNIPER_STATE.value_in(snapshot)
  end
end