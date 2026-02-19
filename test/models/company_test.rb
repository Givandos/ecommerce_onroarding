require "test_helper"

class CompanyTest < ActiveSupport::TestCase
  test "should belong to industry" do
    assert_respond_to Company.new, :industry
  end

  test "should have one onboarding_progress" do
    assert_respond_to Company.new, :onboarding_progress
  end

  test "should have one company_setting" do
    assert_respond_to Company.new, :company_setting
  end

  test "should have many users" do
    assert_respond_to Company.new, :users
  end

  test "should have many products" do
    assert_respond_to Company.new, :products
  end

  test "should have many warehouses" do
    assert_respond_to Company.new, :warehouses
  end

  test "should have many vendors" do
    assert_respond_to Company.new, :vendors
  end

  test "should have many sales_histories" do
    assert_respond_to Company.new, :sales_histories
  end
end
