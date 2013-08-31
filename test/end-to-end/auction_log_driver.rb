java_import org.junit.Assert

require "xmpp_auction_house"

class AuctionLogDriver
  def has_entry(matcher)
    Assert.assertThat(File.read(XMPPAuctionHouse::LOG_FILE_NAME), matcher)
  end

  def clear_log
    File.open(XMPPAuctionHouse::LOG_FILE_NAME, "w") {}
  end
end
