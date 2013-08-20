require "test_helper"

java_import com.objogate.wl.swing.probe.ValueMatcherProbe

java_import org.hamcrest.Matchers

require "ui/main_window"
require "sniper_portfolio"
require "end-to-end/auction_sniper_driver"

describe MainWindow do
  before do
    @main_window = MainWindow.new(SniperPortfolio.new)
    @driver = AuctionSniperDriver.new(100)
  end

  after do
    unless @driver.nil?
      @driver.dispose
    end
  end

  it "makes user request when join button clicked" do
    item_probe = ValueMatcherProbe.new(org.hamcrest.Matchers.equalTo(Item.new("an item-id", 789)), "join request")
    @main_window.add_user_request_listener(
      Class.new do
        def initialize(probe)
          @probe = probe
        end

        def join_auction(item)
          @probe.set_received_value(item)
        end
      end.new(item_probe)
    )
    @driver.start_bidding_for("an item-id", 789)
    @driver.check(item_probe)
  end
end
