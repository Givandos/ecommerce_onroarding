require "test_helper"

class ProductTest < ActiveSupport::TestCase
  test "should belong to company" do
    assert_respond_to Product.new, :company
  end

  test "should belong to category" do
    assert_respond_to Product.new, :category
  end

  test "should have many sales_histories" do
    assert_respond_to Product.new, :sales_histories
  end

  test "should validate presence of name" do
    product = Product.new
    assert_not product.valid?
    assert_includes product.errors[:name], "can't be blank"
  end
end
