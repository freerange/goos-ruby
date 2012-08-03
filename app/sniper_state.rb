class SniperState < Struct.new(:name)
  JOINING = new("JOINING")
  BIDDING = new("BIDDING")
  WINNING = new("WINNING")
  LOST = new("LOST")
  WON = new("WON")

  def ordinal
    return self.class.values.index(self)
  end

  class << self
    def values
      [JOINING, BIDDING, WINNING, LOST, WON]
    end
  end
end
