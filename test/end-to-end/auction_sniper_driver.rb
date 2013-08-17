java_import javax.swing.table.JTableHeader

java_import com.objogate.wl.swing.driver.ComponentDriver
java_import com.objogate.wl.swing.driver.JFrameDriver
java_import com.objogate.wl.swing.driver.JTableDriver
java_import com.objogate.wl.swing.driver.JTableHeaderDriver
java_import com.objogate.wl.swing.gesture.GesturePerformer
java_import com.objogate.wl.swing.AWTEventQueueProber
java_import com.objogate.wl.swing.matcher.JLabelTextMatcher
java_import com.objogate.wl.swing.matcher.IterableComponentsMatcher

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

  def shows_sniper_status(item_id, last_price, last_bid, status_text)
    JTableDriver.new(
      self,
      ComponentDriver.named(MainWindow::SNIPERS_TABLE_NAME)
    ).hasRow(IterableComponentsMatcher.matching(
      JLabelTextMatcher.withLabelText(item_id),
      JLabelTextMatcher.withLabelText(last_price.to_s),
      JLabelTextMatcher.withLabelText(last_bid.to_s),
      JLabelTextMatcher.withLabelText(status_text)
    ))
  end

  def has_column_titles
    JTableHeaderDriver.new(
      self,
      JTableHeader.java_class
    ).hasHeaders(IterableComponentsMatcher.matching(
      JLabelTextMatcher.withLabelText("Item"),
      JLabelTextMatcher.withLabelText("Last Price"),
      JLabelTextMatcher.withLabelText("Last Bid"),
      JLabelTextMatcher.withLabelText("State")
    ))
  end
end
