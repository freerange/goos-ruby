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

    def initialize
      super
      @snapshots = []
    end

    def getColumnCount
      return Column.values.length
    end

    def getRowCount
      return @snapshots.length
    end

    def getValueAt(row_index, column_index)
      Column.at(column_index).value_in(@snapshots[0])
    end

    def getColumnName(column)
      return Column.at(column).name
    end

    def sniper_status_changed(new_sniper_snapshot)
      @snapshots[0] = new_sniper_snapshot
      fireTableRowsUpdated(0, 0)
    end

    def self.text_for(state)
      STATUS_TEXT[state.ordinal]
    end

    def add_sniper(snapshot)
      @snapshots << snapshot
      fireTableRowsInserted(0, 0)
    end
  end

  def initialize(snipers)
    super(APPLICATION_TITLE)
    setName(MAIN_WINDOW_NAME)
    @snipers = snipers
    fill_content_pane(make_snipers_table)
    pack
    setDefaultCloseOperation(JFrame::EXIT_ON_CLOSE)
    setVisible(true)
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
