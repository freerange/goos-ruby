require "env"

java_import org.jivesoftware.smack.MessageListener
java_import org.jivesoftware.smack.XMPPConnection
java_import org.jivesoftware.smack.packet.Message

java_import javax.swing.SwingUtilities

require "ui/main_window"
require "auction_message_translator"
require "auction_sniper"
require "xmpp_auction"

class Main
  ARG_HOSTNAME = 0
  ARG_USERNAME = 1
  ARG_PASSWORD = 2
  ARG_ITEM_ID = 3

  AUCTION_RESOURCE = "Auction"
  ITEM_ID_AS_LOGIN = "auction-%s"
  AUCTION_ID_FORMAT = ITEM_ID_AS_LOGIN + "@%s/" + AUCTION_RESOURCE

  class SwingThreadSniperListener
    def initialize(snipers)
      @snipers = snipers
    end

    def sniper_state_changed(snapshot)
      SwingUtilities.invokeLater do
        @snipers.sniper_state_changed(snapshot)
      end
    end
  end

  def initialize
    @not_to_be_garbage_collected = []
    start_user_interface
  end

  def self.main(*args)
    main = Main.new
    connection = connection(args[ARG_HOSTNAME], args[ARG_USERNAME], args[ARG_PASSWORD]);
    main.disconnect_when_ui_closes(connection);
    args[3..-1].each do |item_id|
      main.join_auction(connection, item_id)
    end
  end

  def join_auction(connection, item_id)
    safely_add_item_to_model(item_id)
    chat = connection.getChatManager.createChat(auction_id(item_id, connection), nil)
    @not_to_be_garbage_collected << chat

    auction = XMPPAuction.new(chat)
    chat.addMessageListener(
      AuctionMessageTranslator.new(
        connection.getUser,
        AuctionSniper.new(item_id, auction, SwingThreadSniperListener.new(@snipers))
      )
    )
    auction.join
  end

  def self.connection(hostname, username, password)
    connection = XMPPConnection.new(hostname)
    connection.connect
    connection.login(username, password, AUCTION_RESOURCE)
    return connection
  end

  def disconnect_when_ui_closes(connection)
    @ui.addWindowListener do |event|
      if event.paramString[/WINDOW_CLOSED/]
        connection.disconnect
      end
    end
  end

  private

  def start_user_interface
    @snipers = MainWindow::SnipersTableModel.new
    SwingUtilities.invokeAndWait do
      @ui = MainWindow.new(@snipers)
    end
  end

  def auction_id(item_id, connection)
    format(AUCTION_ID_FORMAT, item_id, connection.getServiceName)
  end

  def safely_add_item_to_model(item_id)
    SwingUtilities.invokeAndWait do
      @snipers.add_sniper(SniperSnapshot.joining(item_id))
    end
  end
end
