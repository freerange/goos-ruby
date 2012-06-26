java_import javax.swing.JFrame
java_import javax.swing.JTable
java_import javax.swing.JScrollPane
java_import javax.swing.JLabel
java_import javax.swing.border.LineBorder
java_import javax.swing.table.AbstractTableModel
java_import java.awt.Color
java_import java.awt.BorderLayout

class MainWindow < JFrame

  APPLICATION_TITLE = "Auction Sniper"
  MAIN_WINDOW_NAME = "Auction Sniper Main"
  SNIPER_STATUS_NAME = "sniper status"
  SNIPERS_TABLE_NAME = "Snipers Table"

  STATUS_JOINING = "joining"
  STATUS_BIDDING = "bidding"
  STATUS_WINNING = "winning"
  STATUS_WON = "won"
  STATUS_LOST = "lost"

  class SnipersTableModel < AbstractTableModel
    def getColumnCount
      return 1
    end

    def getRowCount
      return 1
    end

    def getValueAt(rowIndex, columnIndex)
      return @status_text
    end

    def initialize
      @status_text = STATUS_JOINING;
    end

    def set_status_text(new_status_text)
      @status_text = new_status_text
      fireTableRowsUpdated(0, 0)
    end
  end

  def initialize
    super(APPLICATION_TITLE)
    setName(MAIN_WINDOW_NAME)
    @snipers = SnipersTableModel.new
    fill_content_pane(make_snipers_table)
    pack
    @sniper_status = create_label(STATUS_JOINING)
    add(@sniper_status)
    setDefaultCloseOperation(JFrame::EXIT_ON_CLOSE)
    setVisible(true)
  end

  def show_status(status_text)
    @snipers.set_status_text(status_text)
  end

  private

  def create_label(initial_text)
    result = JLabel.new(initial_text)
    result.setName(SNIPER_STATUS_NAME)
    result.setBorder(LineBorder.new(Color::BLACK))
    return result
  end

  def fill_content_pane(snipers_table)
    content_pane = getContentPane
    content_pane.setLayout(BorderLayout.new)
    content_pane.add(JScrollPane.new(snipers_table), BorderLayout::CENTER)
  end

  def make_snipers_table
    snipers_table = JTable.new(@snipers)
    snipers_table.setName(SNIPERS_TABLE_NAME)
    return snipers_table
  end
end
