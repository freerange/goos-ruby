require "java"

require "windowlicker-core-DEV.jar"
require "windowlicker-swing-DEV.jar"
require "hamcrest-core-1.2.jar"
require "hamcrest-library-1.2.jar"

# require "cglib-nodep-2.2.jar"
# require "commons-io-1.4.jar"
# require "commons-lang-2.4.jar"
# require "hamcrest-core-SNAPSHOT.jar"
# require "hamcrest-library-SNAPSHOT.jar"
# require "jmock-2.6-SNAPSHOT.jar"
# require "jmock-junit4-2.6-SNAPSHOT.jar"
# require "jmock-legacy-2.6-SNAPSHOT.jar"
# require "junit-dep-4.6.jar"
# require "objenesis-1.0.jar"
# require "smack_3_1_0.jar"
# require "smackx_3_1_0.jar"

java_import com.objogate.wl.swing.driver.JFrameDriver
java_import com.objogate.wl.swing.driver.ComponentDriver
java_import com.objogate.wl.swing.driver.JLabelDriver
java_import com.objogate.wl.swing.gesture.GesturePerformer
java_import com.objogate.wl.swing.AWTEventQueueProber

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
    ).hasText(org.hamcrest.Matchers.equalTo(status_text))
  end
end
