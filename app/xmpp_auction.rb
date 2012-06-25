class XMPPAuction
  JOIN_COMMAND_FORMAT = "SQLVersion: 1.1; Command: JOIN;"
  BID_COMMAND_FORMAT = "SQLVersion: 1.1; Command: BID; Price: %d;"

  def initialize(chat)
    @chat = chat
  end

  def bid(amount)
    send_message(format(BID_COMMAND_FORMAT, amount))
  end

  def join
    send_message(JOIN_COMMAND_FORMAT)
  end

  private

  def send_message(message)
    @chat.sendMessage(message)
  rescue XMPPException => e
    puts %{\n#{e}\n#{e.backtrace.join("\n")}}
  end
end
