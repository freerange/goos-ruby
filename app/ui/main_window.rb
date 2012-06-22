require "java"

java_import javax.swing.JFrame
java_import javax.swing.JLabel
java_import javax.swing.border.LineBorder
java_import java.awt.Color

class MainWindow < JFrame

  MAIN_WINDOW_NAME = "Auction Sniper Main"
  SNIPER_STATUS_NAME = "sniper status"

  STATUS_JOINING = "joining"
  STATUS_LOST = "lost"

  def initialize
    super("Auction Sniper")
    setName(MAIN_WINDOW_NAME)
    @sniper_status = createLabel(STATUS_JOINING)
    add(@sniper_status)
    setDefaultCloseOperation(JFrame::EXIT_ON_CLOSE)
    setVisible(true)
  end

  def show_status(status)
    @sniper_status.setText(status)
  end

  private

  def createLabel(initial_text)
    result = JLabel.new(initial_text)
    result.setName(SNIPER_STATUS_NAME)
    result.setBorder(LineBorder.new(Color::BLACK))
    return result
  end
end
