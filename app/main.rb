require "java"

require "smack_3_1_0.jar"
require "smackx_3_1_0.jar"

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
      Class.new do
        include MessageListener
        def initialize(main)
          @main = main
        end
        def processMessage(aChat, message)
          SwingUtilities.invokeLater(
            Class.new do
              include Runnable
              def initialize(main)
                @main = main
              end
              def run
                @main.ui.show_status(MainWindow::STATUS_LOST)
              end
            end.new(@main)
          )
        end
      end.new(self)
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
      Class.new do
        include Runnable
        def initialize(main)
          @main = main
        end
        def run
          @main.ui = MainWindow.new
        end
      end.new(self)
    )
  end

  def auction_id(item_id, connection)
    format(AUCTION_ID_FORMAT, item_id, connection.getServiceName)
  end
end
