require "main"
require "end-to-end/fake_auction_server"
require "end-to-end/auction_sniper_driver"

class ApplicationRunner
  SNIPER_ID = "sniper"
  SNIPER_PASSWORD = "sniper"
  SNIPER_XMPP_ID = SNIPER_ID + "@" + FakeAuctionServer::XMPP_HOSTNAME + "/Auction"

  def start_bidding_in(auction)
    thread = Thread.new do
      begin
        Main.main(FakeAuctionServer::XMPP_HOSTNAME, SNIPER_ID, SNIPER_PASSWORD, auction.item_id)
      rescue => e
        puts %{\n#{e}\n#{e.backtrace.join("\n")}}
      end
    end
    @driver = AuctionSniperDriver.new(1000)
    @driver.shows_sniper_status(MainWindow::STATUS_JOINING)
  end

  def has_shown_sniper_is_bidding
    @driver.shows_sniper_status(MainWindow::STATUS_BIDDING)
  end

  def shows_sniper_has_lost_auction
    @driver.shows_sniper_status(MainWindow::STATUS_LOST)
  end

  def has_shown_sniper_is_winning
    @driver.shows_sniper_status(MainWindow::STATUS_WINNING)
  end

  def shows_sniper_has_won_auction
    @driver.shows_sniper_status(MainWindow::STATUS_WON)
  end

  def stop
    unless @driver.nil?
      @driver.dispose
    end
  end
end
