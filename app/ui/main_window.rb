java_import javax.swing.JFrame
java_import javax.swing.JTable
java_import javax.swing.JScrollPane
java_import javax.swing.JLabel
java_import javax.swing.border.LineBorder
java_import javax.swing.table.AbstractTableModel
java_import java.awt.Color
java_import java.awt.BorderLayout

require "ui/column"
require "sniper_snapshot"

class MainWindow < JFrame

  APPLICATION_TITLE = "Auction Sniper"
  MAIN_WINDOW_NAME = "Auction Sniper Main"
  SNIPERS_TABLE_NAME = "Snipers Table"

  class SnipersTableModel < AbstractTableModel
    STATUS_TEXT = %w(joining bidding winning won lost)
    STARTING_UP = SniperSnapshot.joining("")

    def initialize
      super
      @sniper_snapshot = STARTING_UP
    end

    def getColumnCount
      return Column.values.length
    end

    def getRowCount
      return 1
    end

    def getValueAt(row_index, column_index)
      Column.at(column_index).value_in(@sniper_snapshot)
    end

    def sniper_status_changed(new_sniper_snapshot)
      @sniper_snapshot = new_sniper_snapshot
      fireTableRowsUpdated(0, 0)
    end

    def self.text_for(state)
      STATUS_TEXT[state.ordinal]
    end
  end

  def initialize
    super(APPLICATION_TITLE)
    setName(MAIN_WINDOW_NAME)
    @snipers = SnipersTableModel.new
    fill_content_pane(make_snipers_table)
    pack
    setDefaultCloseOperation(JFrame::EXIT_ON_CLOSE)
    setVisible(true)
  end

  def sniper_status_changed(sniper_snapshot)
    @snipers.sniper_status_changed(sniper_snapshot)
  end

  private

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
