require "ui/main_window"

class Column < Struct.new(:name)

  ITEM_IDENTIFIER = new("ITEM_IDENTIFIER")
  LAST_PRICE = new("LAST_PRICE")
  LAST_BID = new("LAST_BID")
  SNIPER_STATE = new("SNIPER_STATE")

  def ITEM_IDENTIFIER.value_in(snapshot)
    snapshot.item_id
  end

  def LAST_PRICE.value_in(snapshot)
    snapshot.last_price
  end

  def LAST_BID.value_in(snapshot)
    snapshot.last_bid
  end

  def SNIPER_STATE.value_in(snapshot)
    MainWindow::SnipersTableModel.text_for(snapshot.state)
  end

  def ordinal
    return self.class.values.index(self)
  end

  class << self
    def values
      [ITEM_IDENTIFIER, LAST_PRICE, LAST_BID, SNIPER_STATE]
    end

    def at(offset)
      return values[offset]
    end
  end
end
