java_import javax.swing.table.JTableHeader
java_import javax.swing.JTextField
java_import javax.swing.JButton

java_import com.objogate.wl.swing.driver.ComponentDriver
java_import com.objogate.wl.swing.driver.JFrameDriver
java_import com.objogate.wl.swing.driver.JTableDriver
java_import com.objogate.wl.swing.driver.JTableHeaderDriver
java_import com.objogate.wl.swing.driver.JTextFieldDriver
java_import com.objogate.wl.swing.driver.JButtonDriver
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

  def start_bidding_for(item_id, stop_price)
    text_field(MainWindow::NEW_ITEM_ID_NAME).replaceAllText(item_id)
    text_field(MainWindow::NEW_ITEM_STOP_PRICE_NAME).replaceAllText(java.lang.String.valueOf(stop_price))
    bid_button.click
  end

  def text_field(name)
    driver = JTextFieldDriver.new(self, JTextField.java_class, ComponentDriver.named(name))
    driver.focusWithMouse
    return driver
  end

  def bid_button
    return JButtonDriver.new(self, JButton.java_class, ComponentDriver.named(MainWindow::JOIN_BUTTON_NAME))
  end
end
