java_import javax.swing.JFrame
java_import javax.swing.JTable
java_import javax.swing.JScrollPane
java_import javax.swing.JLabel
java_import javax.swing.border.LineBorder
java_import javax.swing.table.AbstractTableModel
java_import java.awt.Color
java_import java.awt.BorderLayout

require "ui/column"
require "sniper_state"

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
    STARTING_UP = SniperState.new("", 0, 0)

    def initialize
      super
      @status_text = STATUS_JOINING
      @sniper_state = STARTING_UP
    end

    def getColumnCount
      return Column.values.length
    end

    def getRowCount
      return 1
    end

    def getValueAt(row_index, column_index)
      case Column.at(column_index)
      when Column::ITEM_IDENTIFIER
        return @sniper_state.item_id
      when Column::LAST_PRICE
        return @sniper_state.last_price
      when Column::LAST_BID
        return @sniper_state.last_bid
      when Column::SNIPER_STATUS
        return @status_text
      else
        raise new ArgumentError("No column at " + column_index)
      end
    end

    def set_status_text(new_status_text)
      @status_text = new_status_text
      fireTableRowsUpdated(0, 0)
    end

    def sniper_status_changed(new_sniper_state, new_status_text)
      @sniper_state = new_sniper_state
      @status_text = new_status_text
      fireTableRowsUpdated(0, 0)
    end
  end

  def initialize
    super(APPLICATION_TITLE)
    setName(MAIN_WINDOW_NAME)
    @sniper_status = create_label(STATUS_JOINING)
    add(@sniper_status)
    @snipers = SnipersTableModel.new
    fill_content_pane(make_snipers_table)
    pack
    setDefaultCloseOperation(JFrame::EXIT_ON_CLOSE)
    setVisible(true)
  end

  def show_status(status_text)
    @snipers.set_status_text(status_text)
  end

  def sniper_status_changed(sniper_state, status_text)
    @snipers.sniper_status_changed(sniper_state, status_text)
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
