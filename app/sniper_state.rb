class SniperState < Struct.new(:name)
  JOINING = new("JOINING")
  BIDDING = new("BIDDING")
  LOSING = new("LOSING")
  WINNING = new("WINNING")
  LOST = new("LOST")
  WON = new("WON")
  FAILED = new("FAILED")

  def ordinal
    return self.class.values.index(self)
  end

  def JOINING.when_auction_closed; LOST; end
  def BIDDING.when_auction_closed; LOST; end
  def LOSING.when_auction_closed; LOST; end
  def WINNING.when_auction_closed; WON; end

  def when_auction_closed
    raise "Auction is already closed"
  end

  class << self
    def values
      [JOINING, BIDDING, WINNING, LOSING, LOST, WON, FAILED]
    end
  end
end
