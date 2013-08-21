require "test_helper"

require "sniper_launcher"
require "item"

describe SniperLauncher do
  before do
    @auction_house = mock("auction house")
    @sniper_collector = mock("sniper collector")
    @launcher = SniperLauncher.new(@auction_house, @sniper_collector)
    @auction_state = states("auction state").starts_as("not joined")
    @auction = mock("auction")
  end

  it "adds new sniper to collector and then joins auction" do
    item = Item.new("item 123", 456)
    @auction_house.stubs(:auction_for).with(item).returns(@auction)
    @auction.expects(:add_auction_event_listener).with(&sniper_for_item(item.identifier)).when(@auction_state.is("not joined"))
    @sniper_collector.expects(:add_sniper).with(&sniper_for_item(item.identifier)).when(@auction_state.is("not joined"))
    @auction.stubs(:join).then(@auction_state.is("joined"))
    @launcher.join_auction(item)
  end

  private

  def sniper_for_item(item_id)
    lambda do |sniper|
      sniper.snapshot.item_id == item_id
    end
  end
end
