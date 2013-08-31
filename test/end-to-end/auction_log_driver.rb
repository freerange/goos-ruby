require "xmpp_auction_house"

class AuctionLogDriver
  include MiniTest::Assertions

  def has_entry(matcher)
    assert_that File.read(XMPPAuctionHouse::LOG_FILE_NAME), matcher
  end

  def clear_log
    File.open(XMPPAuctionHouse::LOG_FILE_NAME, "w") {}
  end
end
