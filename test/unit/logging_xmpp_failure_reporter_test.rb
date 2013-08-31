require "test_helper"

require "logging_xmpp_failure_reporter"

describe LoggingXMPPFailureReporter do
  before do
    @logger = mock("logger")
    @reporter = LoggingXMPPFailureReporter.new(@logger)
  end

  it "writes message translation failures to a log" do
    @logger.expects(:error).with(%{<auction id> Could not translate message "bad message" because #<RuntimeError: bad>})
    @reporter.cannot_translate_message("auction id", "bad message", RuntimeError.new("bad"))
  end
end