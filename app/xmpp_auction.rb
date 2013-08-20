require "announcer"
require "auction_message_translator"

class XMPPAuction
  JOIN_COMMAND_FORMAT = "SQLVersion: 1.1; Command: JOIN;"
  BID_COMMAND_FORMAT = "SQLVersion: 1.1; Command: BID; Price: %d;"

  AUCTION_RESOURCE = "Auction"
  ITEM_ID_AS_LOGIN = "auction-%s"
  AUCTION_ID_FORMAT = ITEM_ID_AS_LOGIN + "@%s/" + AUCTION_RESOURCE

  def initialize(connection, item_id)
    @auction_event_listeners = Announcer.new
    @chat = connection.getChatManager.createChat(
      auction_id(item_id, connection),
      AuctionMessageTranslator.new(
        connection.getUser,
        @auction_event_listeners.announce
      )
    )
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

  def auction_id(item_id, connection)
    format(AUCTION_ID_FORMAT, item_id, connection.getServiceName)
  end
end
