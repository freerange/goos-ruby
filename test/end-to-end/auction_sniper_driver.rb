java_import com.objogate.wl.swing.driver.ComponentDriver
java_import com.objogate.wl.swing.driver.JFrameDriver
java_import com.objogate.wl.swing.driver.JTableDriver
java_import com.objogate.wl.swing.gesture.GesturePerformer
java_import com.objogate.wl.swing.AWTEventQueueProber
java_import com.objogate.wl.swing.matcher.JLabelTextMatcher
java_import com.objogate.wl.swing.matcher.IterableComponentsMatcher

java_import org.hamcrest.Matchers

require "ui/main_window"
require "main"

class AuctionSniperDriver < JFrameDriver
  def initialize(timeout_millis)
    super(
      GesturePerformer.new,
      JFrameDriver.topLevelFrame(
        ComponentDriver.named(MainWindow::MAIN_WINDOW_NAME),
        ComponentDriver.showingOnScreen
      ),
      AWTEventQueueProber.new(timeout_millis, 100)
    )
  end

  def shows_sniper_status_text(status_text)
    JTableDriver.new(
      self,
      Matchers.anything
    ).hasCell(JLabelTextMatcher.withLabelText(Matchers.equalTo(status_text)))
  end

  def shows_sniper_status(item_id, last_price, last_bid, status_text)
    JTableDriver.new(
      self,
      Matchers.anything
    ).hasRow(IterableComponentsMatcher.matching(
      JLabelTextMatcher.withLabelText(item_id),
      JLabelTextMatcher.withLabelText(last_price.to_s),
      JLabelTextMatcher.withLabelText(last_bid.to_s),
      JLabelTextMatcher.withLabelText(status_text)
    ))
  end
end
