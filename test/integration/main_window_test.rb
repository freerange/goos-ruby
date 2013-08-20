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
    button_probe = ValueMatcherProbe.new(org.hamcrest.Matchers.equalTo("an item-id"), "join request")
    @main_window.add_user_request_listener(
      Class.new do
        def initialize(probe)
          @probe = probe
        end

        def join_auction(item_id)
          @probe.set_received_value(item_id)
        end
      end.new(button_probe)
    )
    @driver.start_bidding_for("an item-id")
    @driver.check(button_probe)
  end
end
