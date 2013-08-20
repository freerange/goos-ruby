require "env"

java_import org.jivesoftware.smack.MessageListener
java_import org.jivesoftware.smack.XMPPConnection
java_import org.jivesoftware.smack.packet.Message

java_import javax.swing.SwingUtilities

require "ui/main_window"
require "xmpp_auction_house"
require "sniper_launcher"
require "sniper_portfolio"

class Main
  ARG_HOSTNAME = 0
  ARG_USERNAME = 1
  ARG_PASSWORD = 2
  ARG_ITEM_ID = 3

  def initialize
    @portfolio = SniperPortfolio.new
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
    @ui.add_user_request_listener(SniperLauncher.new(auction_house, @portfolio))
  end

  private

  def start_user_interface
    SwingUtilities.invokeAndWait do
      @ui = MainWindow.new(@portfolio)
    end
  end
end
