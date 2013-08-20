class XMPPAuctionHouse
  AUCTION_RESOURCE = "Auction"
  ITEM_ID_AS_LOGIN = "auction-%s"
  AUCTION_ID_FORMAT = ITEM_ID_AS_LOGIN + "@%s/" + AUCTION_RESOURCE

  def self.connect(hostname, username, password)
    connection = XMPPConnection.new(hostname)
    connection.connect
    connection.login(username, password, AUCTION_RESOURCE)
    new(connection)
  end

  def initialize(connection)
    @connection = connection
  end

  def auction_for(item_id)
    XMPPAuction.new(@connection, auction_id(item_id, @connection))
  end

  def disconnect
    @connection.disconnect
  end

  private

  def auction_id(item_id, connection)
    format(AUCTION_ID_FORMAT, item_id, connection.getServiceName)
  end
end