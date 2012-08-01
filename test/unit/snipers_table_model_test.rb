require "test_helper"

require "ui/main_window"
require "ui/column"
require "sniper_snapshot"

java_import javax.swing.event.TableModelEvent

describe MainWindow::SnipersTableModel do
  before do
    @listener = mock("TableModelListener")
    @model = MainWindow::SnipersTableModel.new
    @model.addTableModelListener(@listener)
  end

  it "has enough columns" do
    assert_equal Column.values.length, @model.getColumnCount
  end

  it "sets sniper values in columns" do
    @listener.expects(:tableChanged).with do |actual|
      expected = TableModelEvent.new(@model, 0)
      matches = actual.instance_of?(TableModelEvent)
      matches &&= (actual.getColumn == expected.getColumn)
      matches &&= (actual.getFirstRow == expected.getFirstRow)
      matches &&= (actual.getLastRow == expected.getLastRow)
      matches
    end
    @model.sniper_status_changed(SniperSnapshot.new("item id", 555, 666), MainWindow::STATUS_BIDDING)
    assert_column_equals(Column::ITEM_IDENTIFIER, "item id")
    assert_column_equals(Column::LAST_PRICE, 555)
    assert_column_equals(Column::LAST_BID, 666)
    assert_column_equals(Column::SNIPER_STATE, MainWindow::STATUS_BIDDING)
  end

  private

  def assert_column_equals(column, expected)
    row_index, column_index = 0, column.ordinal
    assert_equal expected, @model.getValueAt(row_index, column_index)
  end
end
