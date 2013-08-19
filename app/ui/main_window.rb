java_import javax.swing.JFrame
java_import javax.swing.JTable
java_import javax.swing.JScrollPane
java_import javax.swing.JLabel
java_import javax.swing.JPanel
java_import javax.swing.JTextField
java_import javax.swing.JButton
java_import javax.swing.border.LineBorder
java_import javax.swing.table.AbstractTableModel
java_import java.awt.Color
java_import java.awt.BorderLayout
java_import java.awt.FlowLayout

require "ui/column"
require "sniper_snapshot"
require "announcer"

class MainWindow < JFrame

  APPLICATION_TITLE = "Auction Sniper"
  MAIN_WINDOW_NAME = "Auction Sniper Main"
  SNIPERS_TABLE_NAME = "Snipers Table"
  NEW_ITEM_ID_NAME = "item id"
  JOIN_BUTTON_NAME = "join button"

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
      Column.at(column_index).value_in(@snapshots[row_index])
    end

    def getColumnName(column)
      return Column.at(column).name
    end

    def sniper_state_changed(new_snapshot)
      if index = @snapshots.find_index { |s| new_snapshot.for_same_item_as?(s) }
        @snapshots[index] = new_snapshot
        fireTableRowsUpdated(index, index)
      else
        raise "No existing Sniper state for #{new_snapshot.item_id}"
      end
    end

    def self.text_for(state)
      STATUS_TEXT[state.ordinal]
    end

    def add_sniper(snapshot)
      @snapshots << snapshot
      row = @snapshots.length - 1
      fireTableRowsInserted(row, row)
    end
  end

  def initialize(snipers)
    super(APPLICATION_TITLE)
    setName(MAIN_WINDOW_NAME)
    @snipers = snipers
    @user_requests = Announcer.new
    fill_content_pane(make_snipers_table, make_controls)
    pack
    setDefaultCloseOperation(JFrame::EXIT_ON_CLOSE)
    setVisible(true)
  end

  def add_user_request_listener(user_request_listener)
    @user_requests.add_listener(user_request_listener)
  end

  private

  def fill_content_pane(snipers_table, controls)
    content_pane = getContentPane
    content_pane.setLayout(BorderLayout.new)
    content_pane.add(controls, BorderLayout::NORTH)
    content_pane.add(JScrollPane.new(snipers_table), BorderLayout::CENTER)
  end

  def make_snipers_table
    snipers_table = JTable.new(@snipers)
    snipers_table.setName(SNIPERS_TABLE_NAME)
    return snipers_table
  end

  def make_controls
    controls = JPanel.new(FlowLayout.new)
    item_id_field = JTextField.new
    item_id_field.setColumns(25)
    item_id_field.setName(NEW_ITEM_ID_NAME)
    controls.add(item_id_field)
    join_auction_button = JButton.new("Join Auction")
    join_auction_button.setName(JOIN_BUTTON_NAME)
    join_auction_button.addActionListener do |event|
      @user_requests.announce.join_auction(item_id_field.getText)
    end
    controls.add(join_auction_button)
    return controls
  end
end
