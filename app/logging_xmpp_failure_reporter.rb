class LoggingXMPPFailureReporter
  def initialize(logger)
    @logger = logger
  end

  def cannot_translate_message(auction_id, message, exception)
    @logger.error %{<#{auction_id}> Could not translate message "#{message}" because #{exception.inspect}}
  end
end
