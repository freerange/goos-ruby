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

  class SniperStateDisplayer
    def initialize(ui)
      @ui = ui
    end

    def sniper_bidding(state)
      show_status(MainWindow::STATUS_BIDDING)
    end

    def sniper_winning
      show_status(MainWindow::STATUS_WINNING)
    end

    def sniper_won
      show_status(MainWindow::STATUS_WON)
    end

    def sniper_lost
      show_status(MainWindow::STATUS_LOST)
    end

    private

    def show_status(status)
      SwingUtilities.invokeLater do
        @ui.show_status(status)
      end
    end
  end

  def initialize
    start_user_interface
  end

  def self.main(*args)
    main = Main.new
    main.join_auction(connection(args[ARG_HOSTNAME], args[ARG_USERNAME], args[ARG_PASSWORD]), args[ARG_ITEM_ID])
  end

  def join_auction(connection, item_id)
    disconnect_when_ui_closes(connection)

    chat = connection.getChatManager.createChat(auction_id(item_id, connection), nil)
    @not_to_be_garbage_collected = chat

    auction = XMPPAuction.new(chat)
    chat.addMessageListener(
      AuctionMessageTranslator.new(
        connection.getUser,
        AuctionSniper.new(item_id, auction, SniperStateDisplayer.new(@ui))
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
