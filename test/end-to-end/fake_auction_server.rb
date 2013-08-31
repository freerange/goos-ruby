java_import org.jivesoftware.smack.XMPPConnection
java_import org.jivesoftware.smack.ChatManagerListener
java_import org.jivesoftware.smack.MessageListener
java_import org.jivesoftware.smack.packet.Message

require "xmpp_auction"

class SingleMessageListener
  include MessageListener
  include MiniTest::Assertions
  include Ramcrest::HasAttribute

  def initialize
    @messages = Queue.new
  end

  def processMessage(chat, message)
    @messages.push(message)
  end

  def receives_a_message(message_matcher)
    message = @messages.pop
    assert_that message, has_attribute(:body, message_matcher)
  end
end

class FakeAuctionServer
  include MiniTest::Assertions
  include Ramcrest::EqualTo

  ITEM_ID_AS_LOGIN = "auction-%s"
  AUCTION_RESOURCE = "Auction"
  XMPP_HOSTNAME = "localhost"
  AUCTION_PASSWORD = "auction"

  attr_reader :item_id

  def initialize(item_id)
    @item_id = item_id
    @connection = XMPPConnection.new(XMPP_HOSTNAME)
    @message_listener = SingleMessageListener.new
  end

  def start_selling_item
    @connection.connect
    @connection.login(format(ITEM_ID_AS_LOGIN, @item_id), AUCTION_PASSWORD, AUCTION_RESOURCE)
    @connection.getChatManager.addChatListener do |chat, createdLocally|
      @current_chat = chat
      chat.addMessageListener(@message_listener)
    end
  end

  def send_invalid_message_containing(broken_message)
    @current_chat.sendMessage(broken_message)
  end

  def report_price(price, increment, bidder)
    @current_chat.sendMessage(format("SQLVersion: 1.1; Event: PRICE; CurrentPrice: %d; Increment: %d; Bidder: %s;", price, increment, bidder))
  end

  def has_received_join_request_from(sniper_id)
    receives_a_message_matching(sniper_id, equal_to(XMPPAuction::JOIN_COMMAND_FORMAT))
  end

  def has_received_bid(bid, sniper_id)
    receives_a_message_matching(sniper_id, equal_to(format(XMPPAuction::BID_COMMAND_FORMAT, bid)))
  end

  def announce_closed
    @current_chat.sendMessage("SQLVersion: 1.1; Event: CLOSE;")
  end

  def stop
    @connection.disconnect
  end

  private

  def receives_a_message_matching(sniper_id, message_matcher)
    @message_listener.receives_a_message(message_matcher)
    assert_that(@current_chat.getParticipant, equal_to(sniper_id))
  end
end
