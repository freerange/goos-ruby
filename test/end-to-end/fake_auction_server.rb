java_import org.jivesoftware.smack.XMPPConnection
java_import org.jivesoftware.smack.ChatManagerListener
java_import org.jivesoftware.smack.MessageListener
java_import org.jivesoftware.smack.packet.Message

java_import java.util.concurrent.ArrayBlockingQueue
java_import java.util.concurrent.TimeUnit

java_import org.hamcrest.Matchers
java_import org.hamcrest.core.Is

class SingleMessageListener
  include MessageListener
  include MiniTest::Assertions

  def initialize
    @messages = ArrayBlockingQueue.new(1)
  end

  def processMessage(chat, message)
    @messages.add(message)
  end

  def receives_a_message
    refute_nil @messages.poll(5, TimeUnit::SECONDS)
  end
end

class FakeAuctionServer
  ITEM_ID_AS_LOGIN = "auction-%s"
  AUCTION_RESOURCE = "Auction"
  XMPP_HOSTNAME = "localhost"
  AUCTION_PASSWORD = "auction"

  attr_reader :item_id, :message_listener
  attr_writer :current_chat

  def initialize(item_id)
    @item_id = item_id
    @connection = XMPPConnection.new(XMPP_HOSTNAME)
    @message_listener = SingleMessageListener.new
  end

  def start_selling_item
    @connection.connect
    @connection.login(format(ITEM_ID_AS_LOGIN, item_id), AUCTION_PASSWORD, AUCTION_RESOURCE)
    @connection.getChatManager.addChatListener(
      Class.new do
        include ChatManagerListener
        def initialize(auction_server)
          @auction_server = auction_server
        end
        def chatCreated(chat, createdLocally)
          @auction_server.current_chat = chat
          chat.addMessageListener(@auction_server.message_listener)
        end
      end.new(self)
    )
  end

  def has_received_join_request_from_sniper
    @message_listener.receives_a_message
  end

  def announce_closed
    @current_chat.sendMessage(Message.new)
  end

  def stop
    @connection.disconnect
  end
end
