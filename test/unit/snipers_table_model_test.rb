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

  it "notifies listeners when adding a sniper" do
    joining = SniperSnapshot.joining("item123")
    @listener.expects(:tableChanged).with(&an_insertion_at_row(0))
    assert_equal 0, @model.getRowCount
    @model.add_sniper(joining)
    assert_equal 1, @model.getRowCount
    assert_row_matches_snapshot(0, joining)
  end

  it "holds snipers in addition order" do
    @listener.stubs(:tableChanged)
    @model.add_sniper(SniperSnapshot.joining("item 0"))
    @model.add_sniper(SniperSnapshot.joining("item 1"))
    assert_equal "item 0", cell_value(0, Column::ITEM_IDENTIFIER)
    assert_equal "item 1", cell_value(1, Column::ITEM_IDENTIFIER)
  end

  it "updates correct row for sniper" do
    @listener.stubs(:tableChanged).with(&any_insertion_event)
    @listener.expects(:tableChanged).with(&a_change_in_row(1))
    sniper_0 = SniperSnapshot.joining("item 0")
    sniper_1 = SniperSnapshot.joining("item 1")
    @model.add_sniper(sniper_0)
    @model.add_sniper(sniper_1)
    winning_1 = sniper_1.winning(123)
    @model.sniper_status_changed(winning_1)
    assert_row_matches_snapshot(1, winning_1)
  end

  it "raises exception if no existing sniper for an update" do
    assert_raises(RuntimeError) do
      @model.sniper_status_changed(SniperSnapshot.new("item 1", 123, 234, SniperState::WINNING))
    end
  end

  it "sets sniper values in columns" do
    joining = SniperSnapshot.joining("item123")
    bidding = joining.bidding(555, 666)
    @listener.stubs(:tableChanged).with(&any_insertion_event)
    @listener.expects(:tableChanged).with(&a_change_in_row(0))
    @model.add_sniper(joining)
    @model.sniper_status_changed(bidding)
    assert_row_matches_snapshot(0, bidding)
  end

  private

  def an_insertion_at_row(row)
    lambda do |event|
      expected = TableModelEvent.new(@model, row, row, TableModelEvent::ALL_COLUMNS, TableModelEvent::INSERT)
      (
        event.instance_of?(TableModelEvent) &&
        (event.getColumn == expected.getColumn) &&
        (event.getFirstRow == expected.getFirstRow) &&
        (event.getLastRow == expected.getLastRow) &&
        (event.getType == expected.getType)
      )
    end
  end

  def any_insertion_event
    lambda do |event|
      (
        event.instance_of?(TableModelEvent) &&
        (event.getType == TableModelEvent::INSERT)
      )
    end
  end

  def a_change_in_row(row)
    lambda do |event|
      expected = TableModelEvent.new(@model, row)
      (
        event.instance_of?(TableModelEvent) &&
        (event.getColumn == expected.getColumn) &&
        (event.getFirstRow == expected.getFirstRow) &&
        (event.getLastRow == expected.getLastRow) &&
        (event.getType == expected.getType)
      )
    end
  end

  def assert_row_matches_snapshot(row, snapshot)
    assert_equal snapshot.item_id, cell_value(row, Column::ITEM_IDENTIFIER)
    assert_equal snapshot.last_price, cell_value(row, Column::LAST_PRICE)
    assert_equal snapshot.last_bid, cell_value(row, Column::LAST_BID)
    assert_equal MainWindow::SnipersTableModel.text_for(snapshot.state), cell_value(row, Column::SNIPER_STATE)
  end

  def cell_value(row_index, column)
    @model.getValueAt(row_index, column.ordinal)
  end
end
