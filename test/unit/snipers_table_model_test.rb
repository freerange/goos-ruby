require "test_helper"

require "ui/main_window"
require "ui/column"
require "sniper_snapshot"
require "sniper_state"

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

  it "sets up column headings" do
    Column.values.each do |column|
      assert_equal column.name, @model.getColumnName(column.ordinal)
    end
  end

  it "sets sniper values in columns" do
    @listener.expects(:tableChanged).with(&a_row_changed_event_based_on(@model))
    @model.sniper_status_changed(SniperSnapshot.new("item id", 555, 666, SniperState::BIDDING))
    assert_column_equals(Column::ITEM_IDENTIFIER, "item id")
    assert_column_equals(Column::LAST_PRICE, 555)
    assert_column_equals(Column::LAST_BID, 666)
    assert_column_equals(Column::SNIPER_STATE, MainWindow::SnipersTableModel.text_for(SniperState::BIDDING))
  end

  private

  def a_row_changed_event_based_on(model)
    lambda do |event|
      expected = TableModelEvent.new(model, 0)
      (
        event.instance_of?(TableModelEvent) &&
        (event.getColumn == expected.getColumn) &&
        (event.getFirstRow == expected.getFirstRow) &&
        (event.getLastRow == expected.getLastRow)
      )
    end
  end

  def assert_column_equals(column, expected)
    row_index, column_index = 0, column.ordinal
    assert_equal expected, @model.getValueAt(row_index, column_index)
  end
end
