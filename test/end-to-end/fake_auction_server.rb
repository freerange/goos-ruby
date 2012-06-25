java_import org.jivesoftware.smack.XMPPConnection
java_import org.jivesoftware.smack.ChatManagerListener
java_import org.jivesoftware.smack.MessageListener
java_import org.jivesoftware.smack.packet.Message

java_import java.util.concurrent.ArrayBlockingQueue
java_import java.util.concurrent.TimeUnit

java_import org.junit.Assert
java_import org.hamcrest.Matchers

class SingleMessageListener
  include MessageListener
  include MiniTest::Assertions

  def initialize
    @messages = ArrayBlockingQueue.new(1)
  end

  def processMessage(chat, message)
    @messages.add(message)
  end

  def receives_a_message(message_matcher)
    message = @messages.poll(5, TimeUnit::SECONDS)
    Assert.assertThat("Message", message, Matchers.is(Matchers.notNullValue()))
    Assert.assertThat(message.getBody, message_matcher)
  end
end

class FakeAuctionServer
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

  def report_price(price, increment, bidder)
    @current_chat.sendMessage(format("SOLVersion: 1.1; Event: PRICE; CurrentPrice: %d; Increment: %d; Bidder: %s;", price, increment, bidder))
  end

  def has_received_join_request_from(sniper_id)
    receives_a_message_matching(sniper_id, Matchers.equalTo(Main::JOIN_COMMAND_FORMAT))
  end

  def has_received_bid(bid, sniper_id)
    receives_a_message_matching(sniper_id, Matchers.equalTo(format(Main::BID_COMMAND_FORMAT, bid)))
  end

  def announce_closed
    @current_chat.sendMessage("SOLVersion: 1.1; Event: CLOSE;");
  end

  def stop
    @connection.disconnect
  end

  private

  def receives_a_message_matching(sniper_id, message_matcher)
    @message_listener.receives_a_message(message_matcher)
    Assert.assertThat(@current_chat.getParticipant, Matchers.equalTo(sniper_id));
  end
end
