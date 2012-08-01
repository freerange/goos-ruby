class Column < Struct.new(:name)

  ITEM_IDENTIFIER = new("ITEM_IDENTIFIER")
  LAST_PRICE = new("LAST_PRICE")
  LAST_BID = new("LAST_BID")
  SNIPER_STATUS = new("SNIPER_STATUS")

  def ordinal
    return self.class.values.index(self)
  end

  class << self
    def values
      [ITEM_IDENTIFIER, LAST_PRICE, LAST_BID, SNIPER_STATUS]
    end

    def at(offset)
      return values[offset]
    end
  end
end
