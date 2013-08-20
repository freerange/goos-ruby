require "test_helper"

require "ui/main_window"
require "ui/column"
require "sniper_snapshot"
require "sniper_state"

java_import javax.swing.event.TableModelEvent

describe MainWindow::SnipersTableModel do
  ITEM_ID = "item 0"

  before do
    @listener = mock("TableModelListener")
    @model = MainWindow::SnipersTableModel.new
    @model.addTableModelListener(@listener)
    @sniper = AuctionSniper.new(ITEM_ID, nil); 
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
    @listener.expects(:tableChanged).with(&an_insertion_at_row(0))
    assert_equal 0, @model.getRowCount
    @model.add_sniper(@sniper)
    assert_equal 1, @model.getRowCount
    assert_row_matches_snapshot(0, SniperSnapshot.joining(ITEM_ID))
  end

  it "holds snipers in addition order" do
    sniper2 = AuctionSniper.new("item 1", nil)
    @listener.stubs(:tableChanged)
    @model.add_sniper(@sniper)
    @model.add_sniper(sniper2)
    assert_equal ITEM_ID, cell_value(0, Column::ITEM_IDENTIFIER)
    assert_equal "item 1", cell_value(1, Column::ITEM_IDENTIFIER)
  end

  it "updates correct row for sniper" do
    sniper2 = AuctionSniper.new("item 1", nil)
    @listener.stubs(:tableChanged).with(&any_insertion_event)
    @listener.expects(:tableChanged).with(&a_change_in_row(1))
    @model.add_sniper(@sniper)
    @model.add_sniper(sniper2)
    winning_2 = sniper2.snapshot.winning(123)
    @model.sniper_state_changed(winning_2)
    assert_row_matches_snapshot(1, winning_2)
  end

  it "raises exception if no existing sniper for an update" do
    assert_raises(RuntimeError) do
      @model.sniper_state_changed(SniperSnapshot.new("item 1", 123, 234, SniperState::WINNING))
    end
  end

  it "sets sniper values in columns" do
    bidding = @sniper.snapshot.bidding(555, 666)
    @listener.stubs(:tableChanged).with(&any_insertion_event)
    @listener.expects(:tableChanged).with(&a_change_in_row(0))
    @model.add_sniper(@sniper)
    @model.sniper_state_changed(bidding)
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
