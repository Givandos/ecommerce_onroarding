require "test_helper"

class WarehouseTest < ActiveSupport::TestCase
  test "should belong to company" do
    assert_respond_to Warehouse.new, :company
  end

  test "should validate presence of name" do
    warehouse = Warehouse.new
    assert_not warehouse.valid?
    assert_includes warehouse.errors[:name], "can't be blank"
  end
end
