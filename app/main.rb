require "env"

java_import org.jivesoftware.smack.MessageListener
java_import org.jivesoftware.smack.XMPPConnection
java_import org.jivesoftware.smack.packet.Message

java_import javax.swing.SwingUtilities

require "ui/main_window"
require "auction_message_translator"

class Main
  ARG_HOSTNAME = 0
  ARG_USERNAME = 1
  ARG_PASSWORD = 2
  ARG_ITEM_ID = 3

  AUCTION_RESOURCE = "Auction"
  ITEM_ID_AS_LOGIN = "auction-%s"
  AUCTION_ID_FORMAT = ITEM_ID_AS_LOGIN + "@%s/" + AUCTION_RESOURCE

  JOIN_COMMAND_FORMAT = "SQLVersion: 1.1; Command: JOIN;"
  BID_COMMAND_FORMAT = "SQLVersion: 1.1; Command: BID; Price: %d;"

  def initialize
    start_user_interface
  end

  def self.main(*args)
    main = Main.new
    main.join_auction(connection(args[ARG_HOSTNAME], args[ARG_USERNAME], args[ARG_PASSWORD]), args[ARG_ITEM_ID])
  end

  def join_auction(connection, item_id)
    disconnect_when_ui_closes(connection)
    chat = connection.getChatManager.createChat(
      auction_id(item_id, connection),
      AuctionMessageTranslator.new(self)
    )
    @not_to_be_garbage_collected = chat
    chat.sendMessage(JOIN_COMMAND_FORMAT)
  end

  def auction_closed
    SwingUtilities.invokeLater do
      @ui.show_status(MainWindow::STATUS_LOST)
    end
  end

  def self.connection(hostname, username, password)
    connection = XMPPConnection.new(hostname)
    connection.connect
    connection.login(username, password, AUCTION_RESOURCE)
    return connection
  end

  private

  def start_user_interface
    SwingUtilities.invokeAndWait do
      @ui = MainWindow.new
    end
  end

  def auction_id(item_id, connection)
    format(AUCTION_ID_FORMAT, item_id, connection.getServiceName)
  end

  def disconnect_when_ui_closes(connection)
    @ui.addWindowListener do |event|
      if event.paramString[/WINDOW_CLOSED/]
        connection.disconnect
      end
    end
  end
end
