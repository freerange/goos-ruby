require "env"

java_import org.jivesoftware.smack.MessageListener
java_import org.jivesoftware.smack.XMPPConnection
java_import org.jivesoftware.smack.packet.Message

java_import javax.swing.SwingUtilities
java_import java.lang.Runnable

require "ui/main_window"

class Main
  ARG_HOSTNAME = 0
  ARG_USERNAME = 1
  ARG_PASSWORD = 2
  ARG_ITEM_ID = 3

  AUCTION_RESOURCE = "Auction"
  ITEM_ID_AS_LOGIN = "auction-%s"
  AUCTION_ID_FORMAT = ITEM_ID_AS_LOGIN + "@%s/" + AUCTION_RESOURCE

  attr_accessor :ui

  def initialize
    start_user_interface
  end

  def self.main(*args)
    main = Main.new
    main.join_auction(connection(args[ARG_HOSTNAME], args[ARG_USERNAME], args[ARG_PASSWORD]), args[ARG_ITEM_ID])
  end

  def join_auction(connection, item_id)
    chat = connection.getChatManager.createChat(
      auction_id(item_id, connection),
      implement(MessageListener, processMessage: -> aChat, message {
        SwingUtilities.invokeLater(
          implement(Runnable, run: -> {
            context.ui.show_status(MainWindow::STATUS_LOST)
          })
        )
      })
    )
    @not_to_be_garbage_collected = chat
    chat.sendMessage(Message.new)
  end

  def self.connection(hostname, username, password)
    connection = XMPPConnection.new(hostname)
    connection.connect
    connection.login(username, password, AUCTION_RESOURCE)
    return connection
  end

  private

  def start_user_interface
    SwingUtilities.invokeAndWait(
      implement(Runnable, run: -> {
        context.ui = MainWindow.new
      })
    )
  end

  def auction_id(item_id, connection)
    format(AUCTION_ID_FORMAT, item_id, connection.getServiceName)
  end
end
