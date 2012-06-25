class AuctionMessageTranslator
  def initialize(listener)
    @listener = listener
  end

  def processMessage(chat, message)
    event = unpack_event_from(message)
    type = event.fetch("Event")
    if "CLOSE" == type
      @listener.auction_closed
    elsif "PRICE" == type
      @listener.current_price(
        Integer(event.fetch("CurrentPrice")),
        Integer(event.fetch("Increment"))
      )
    end
  end

  private

  def unpack_event_from(message)
    event = Hash.new
    message.getBody.split(";").each do |element|
      pair = element.split(":")
      event.store(pair[0].strip, pair[1].strip)
    end
    return event
  end
end
