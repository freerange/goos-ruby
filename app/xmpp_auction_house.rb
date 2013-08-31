java_import org.jivesoftware.smack.XMPPConnection

require "logger"
require "logging_xmpp_failure_reporter"
require "xmpp_auction"

class XMPPAuctionHouse
  AUCTION_RESOURCE = "Auction"
  ITEM_ID_AS_LOGIN = "auction-%s"
  AUCTION_ID_FORMAT = ITEM_ID_AS_LOGIN + "@%s/" + AUCTION_RESOURCE
  LOG_FILE_NAME = "auction-sniper.log"

  def self.connect(hostname, username, password)
    connection = XMPPConnection.new(hostname)
    connection.connect
    connection.login(username, password, AUCTION_RESOURCE)
    new(connection)
  end

  def initialize(connection)
    @connection = connection
    @failure_reporter = LoggingXMPPFailureReporter.new(Logger.new(LOG_FILE_NAME))
  end

  def auction_for(item)
    XMPPAuction.new(@connection, auction_id(item.identifier, @connection), @failure_reporter)
  end

  def disconnect
    @connection.disconnect
  end

  private

  def auction_id(item_id, connection)
    format(AUCTION_ID_FORMAT, item_id, connection.getServiceName)
  end
end