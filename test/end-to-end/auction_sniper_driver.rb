require "java"

require "windowlicker-core-DEV.jar"
require "windowlicker-swing-DEV.jar"
require "hamcrest-core-1.2.jar"
require "hamcrest-library-1.2.jar"

java_import com.objogate.wl.swing.driver.ComponentDriver
java_import com.objogate.wl.swing.driver.JFrameDriver
java_import com.objogate.wl.swing.driver.JLabelDriver
java_import com.objogate.wl.swing.gesture.GesturePerformer
java_import com.objogate.wl.swing.AWTEventQueueProber

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

  def shows_sniper_status(status_text)
    JLabelDriver.new(
      self, ComponentDriver.named(MainWindow::SNIPER_STATUS_NAME)
    ).hasText(Matchers.equalTo(status_text))
  end
end
