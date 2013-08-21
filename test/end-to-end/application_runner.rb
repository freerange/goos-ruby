require "main"
require "ui/snipers_table_model"
require "end-to-end/fake_auction_server"
require "end-to-end/auction_sniper_driver"

class ApplicationRunner
  SNIPER_ID = "sniper"
  SNIPER_PASSWORD = "sniper"
  SNIPER_XMPP_ID = SNIPER_ID + "@" + FakeAuctionServer::XMPP_HOSTNAME + "/Auction"

  def start_bidding_in(*auctions)
    start_sniper
    auctions.each { |a| open_bidding_for(a, java.lang.Integer::MAX_VALUE) }
  end

  def start_bidding_with_stop_price(auction, stop_price)
    start_sniper
    open_bidding_for(auction, stop_price)
  end

  def has_shown_sniper_is_bidding(auction, last_price, last_bid)
    @driver.shows_sniper_status(auction.item_id, last_price, last_bid, SnipersTableModel.text_for(SniperState::BIDDING))
  end

  def shows_sniper_has_lost_auction(auction, last_price, last_bid)
    @driver.shows_sniper_status(auction.item_id, last_price, last_bid, SnipersTableModel.text_for(SniperState::LOST))
  end

  def has_shown_sniper_is_losing(auction, last_price, last_bid)
    @driver.shows_sniper_status(auction.item_id, last_price, last_bid, SnipersTableModel.text_for(SniperState::LOSING))
  end

  def has_shown_sniper_is_winning(auction, winning_bid)
    @driver.shows_sniper_status(auction.item_id, winning_bid, winning_bid, SnipersTableModel.text_for(SniperState::WINNING))
  end

  def shows_sniper_has_won_auction(auction, last_price)
    @driver.shows_sniper_status(auction.item_id, last_price, last_price, SnipersTableModel.text_for(SniperState::WON))
  end

  def shows_sniper_has_failed(auction)
    @driver.shows_sniper_status(auction.item_id, 0, 0, SnipersTableModel.text_for(SniperState::FAILED))
  end

  def reports_invalid_message(auction, broken_message)
  end

  def stop
    unless @driver.nil?
      @driver.dispose
    end
  end

  private

  def start_sniper
    thread = java.lang.Thread.new do
      begin
        Main.main(FakeAuctionServer::XMPP_HOSTNAME, SNIPER_ID, SNIPER_PASSWORD)
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
  end

  def open_bidding_for(auction, stop_price)
    item_id = auction.item_id
    @driver.start_bidding_for(item_id, stop_price)
    @driver.shows_sniper_status(item_id, 0, 0, SnipersTableModel.text_for(SniperState::JOINING))
  end
end
