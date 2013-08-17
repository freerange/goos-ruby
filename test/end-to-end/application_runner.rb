require "main"
require "end-to-end/fake_auction_server"
require "end-to-end/auction_sniper_driver"

class ApplicationRunner
  SNIPER_ID = "sniper"
  SNIPER_PASSWORD = "sniper"
  SNIPER_XMPP_ID = SNIPER_ID + "@" + FakeAuctionServer::XMPP_HOSTNAME + "/Auction"

  def start_bidding_in(auction)
    thread = java.lang.Thread.new do
      begin
        Main.main(FakeAuctionServer::XMPP_HOSTNAME, SNIPER_ID, SNIPER_PASSWORD, auction.item_id)
      rescue => e
        puts %{\n#{e}\n#{e.backtrace.join("\n")}}
      end
    end
    thread.setName("Test Application")
    thread.setDaemon(true)
    thread.start
    @driver = AuctionSniperDriver.new(1000)
    @driver.hasTitle(MainWindow::APPLICATION_TITLE)
    @driver.has_column_titles
    starting_up = MainWindow::SnipersTableModel::STARTING_UP
    @driver.shows_sniper_status(starting_up.item_id, starting_up.last_price, starting_up.last_bid, MainWindow::SnipersTableModel.text_for(SniperState::JOINING))
  end

  def has_shown_sniper_is_bidding(auction, last_price, last_bid)
    @driver.shows_sniper_status(auction.item_id, last_price, last_bid, MainWindow::SnipersTableModel.text_for(SniperState::BIDDING))
  end

  def shows_sniper_has_lost_auction(auction, last_price, last_bid)
    @driver.shows_sniper_status(auction.item_id, last_price, last_bid, MainWindow::SnipersTableModel.text_for(SniperState::LOST))
  end

  def has_shown_sniper_is_winning(auction, winning_bid)
    @driver.shows_sniper_status(auction.item_id, winning_bid, winning_bid, MainWindow::SnipersTableModel.text_for(SniperState::WINNING))
  end

  def shows_sniper_has_won_auction(auction, last_price)
    @driver.shows_sniper_status(auction.item_id, last_price, last_price, MainWindow::SnipersTableModel.text_for(SniperState::WON))
  end

  def stop
    unless @driver.nil?
      @driver.dispose
    end
  end
end
