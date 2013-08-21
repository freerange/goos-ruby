java_import javax.swing.table.AbstractTableModel

require "ui/column"
require "ui/swing_thread_sniper_listener"

class SnipersTableModel < AbstractTableModel
  STATUS_TEXT = %w(joining bidding winning losing won lost failed)

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

  def sniper_added(sniper)
    add_sniper_snapshot(sniper.snapshot)
    sniper.add_sniper_listener(SwingThreadSniperListener.new(self))
  end

  private

  def add_sniper_snapshot(snapshot)
    @snapshots << snapshot
    row = @snapshots.length - 1
    fireTableRowsInserted(row, row)
  end
end

