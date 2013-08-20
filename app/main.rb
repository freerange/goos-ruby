require "env"

java_import org.jivesoftware.smack.MessageListener
java_import org.jivesoftware.smack.XMPPConnection
java_import org.jivesoftware.smack.packet.Message

java_import javax.swing.SwingUtilities

require "ui/main_window"
require "auction_sniper"
require "xmpp_auction_house"

class Main
  ARG_HOSTNAME = 0
  ARG_USERNAME = 1
  ARG_PASSWORD = 2
  ARG_ITEM_ID = 3

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
    start_user_interface
  end

  def self.main(*args)
    main = Main.new
    auction_house = XMPPAuctionHouse.connect(args[ARG_HOSTNAME], args[ARG_USERNAME], args[ARG_PASSWORD])
    main.disconnect_when_ui_closes(auction_house)
    main.add_user_request_listener_for(auction_house)
  end

  def disconnect_when_ui_closes(auction_house)
    @ui.addWindowListener do |event|
      if event.paramString[/WINDOW_CLOSED/]
        auction_house.disconnect
      end
    end
  end

  def add_user_request_listener_for(auction_house)
    @ui.add_user_request_listener(
      Class.new do
        def initialize(auction_house, snipers)
          @auction_house, @snipers = auction_house, snipers
          @not_to_be_garbage_collected = []
        end

        def join_auction(item_id)
          @snipers.add_sniper(SniperSnapshot.joining(item_id))
          auction = @auction_house.auction_for(item_id)
          @not_to_be_garbage_collected << auction
          auction.add_auction_event_listener(AuctionSniper.new(item_id, auction, SwingThreadSniperListener.new(@snipers)))
          auction.join
        end
      end.new(auction_house, @snipers)
    )
  end

  private

  def start_user_interface
    @snipers = MainWindow::SnipersTableModel.new
    SwingUtilities.invokeAndWait do
      @ui = MainWindow.new(@snipers)
    end
  end
end
