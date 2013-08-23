require "price_source"

class AuctionMessageTranslator

  class AuctionEvent
    def initialize
      @fields = Hash.new
    end

    def type
      return get("Event")
    end

    def current_price
      return get_int("CurrentPrice")
    end

    def increment
      return get_int("Increment")
    end

    def get_int(field_name)
      return Integer(get(field_name))
    end

    def get(field_name)
      return @fields.fetch(field_name)
    end

    def add_field(field)
      pair = field.split(":")
      @fields.store(pair[0].strip, pair[1].strip)
    end

    def is_from(sniper_id)
      return (sniper_id == bidder) ? PriceSource::FROM_SNIPER : PriceSource::FROM_OTHER_BIDDER
    end

    private

    def bidder
      return get("Bidder")
    end

    class << self
      def from(message_body)
        event = AuctionEvent.new
        fields_in(message_body).each do |field|
          event.add_field(field)
        end
        return event
      end

      def fields_in(message_body)
        message_body.split(";")
      end
    end
  end

  def initialize(sniper_id, listener)
    @sniper_id, @listener = sniper_id, listener
  end

  def processMessage(chat, message)
    message_body = message.getBody
    translate(message_body)
  rescue => parse_exception
    @listener.auction_failed
  end

  def translate(message_body)
    event = AuctionEvent.from(message_body)
    event_type = event.type
    if "CLOSE" == event_type
      @listener.auction_closed
    elsif "PRICE" == event_type
      @listener.current_price(event.current_price, event.increment, event.is_from(@sniper_id))
    end
  end
end
