require "announcer"
require "auction_message_translator"

class XMPPAuction
  JOIN_COMMAND_FORMAT = "SQLVersion: 1.1; Command: JOIN;"
  BID_COMMAND_FORMAT = "SQLVersion: 1.1; Command: BID; Price: %d;"

  def initialize(connection, auction_id)
    @auction_event_listeners = Announcer.new
    translator = translator_for(connection)
    @chat = connection.getChatManager.createChat(auction_id, translator)
    add_auction_event_listener(chat_disconnector_for(translator))
  end

  def bid(amount)
    send_message(format(BID_COMMAND_FORMAT, amount))
  end

  def join
    send_message(JOIN_COMMAND_FORMAT)
  end

  def add_auction_event_listener(listener)
    @auction_event_listeners.add_listener(listener)
  end

  private

  def send_message(message)
    @chat.sendMessage(message)
  rescue XMPPException => e
    puts %{\n#{e}\n#{e.backtrace.join("\n")}}
  end

  def translator_for(connection)
    AuctionMessageTranslator.new(connection.getUser, @auction_event_listeners.announce)
  end

  def chat_disconnector_for(translator)
    Class.new do
      def initialize(chat, translator)
        @chat, @translator = chat, translator
      end

      def auction_failed
        @chat.removeMessageListener(@translator)
      end

      def auction_closed; end
      def current_price(price, increment, price_source); end
    end.new(@chat, translator)
  end
end
