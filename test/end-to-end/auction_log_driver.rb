java_import org.junit.Assert

class AuctionLogDriver
  LOG_FILE_NAME = "auction-sniper.log"

  def has_entry(matcher)
    Assert.assertThat(File.read(LOG_FILE_NAME), matcher)
  end

  def clear_log
    File.open(LOG_FILE_NAME, "w") {}
  end
end
