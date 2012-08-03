require "sniper_state"

class SniperSnapshot < Struct.new(:item_id, :last_price, :last_bid, :state)
  def self.joining(new_item_id)
    SniperSnapshot.new(new_item_id, 0, 0, SniperState::JOINING)
  end

  def bidding(new_last_price, new_last_bid)
    SniperSnapshot.new(item_id, new_last_price, new_last_bid, SniperState::BIDDING)
  end

  def winning(new_last_price)
    SniperSnapshot.new(item_id, new_last_price, last_bid, SniperState::WINNING)
  end

  def closed
    SniperSnapshot.new(item_id, last_price, last_bid, state.when_auction_closed)
  end
end
