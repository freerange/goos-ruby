class Item < Struct.new(:identifier, :stop_price)
  def to_s
    "Item: #{identifier}, stop price: #{stop_price}"
  end

  def allows_bid?(bid)
    bid <= stop_price
  end
end

