require "test_helper"

class VendorTest < ActiveSupport::TestCase
  test "should belong to company" do
    assert_respond_to Vendor.new, :company
  end

  test "should have many products" do
    assert_respond_to Vendor.new, :products
  end

  test "should validate presence of name" do
    vendor = Vendor.new
    assert_not vendor.valid?
    assert_includes vendor.errors[:name], "can't be blank"
  end
end
