require "test_helper"

class SyncStatusServiceTest < ActiveSupport::TestCase
  setup do
    @company = companies(:one)
    @service = SyncStatusService.new(@company)
  end

  test "initializes with company" do
    assert_equal @company, @service.company
  end

  test "progress_for returns progress percentage for valid sync type" do
    progress = @service.progress_for(:products)
    assert_instance_of Integer, progress
    assert_operator progress, :>=, 0
    assert_operator progress, :<=, 100
  end

  test "progress_for returns 100 for invalid sync type" do
    progress = @service.progress_for(:invalid_type)
    assert_equal 100, progress
  end

  test "all_progress returns hash with all sync types" do
    progress = @service.all_progress

    assert_instance_of Hash, progress
    assert_includes progress.keys, :products
    assert_includes progress.keys, :warehouses
    assert_includes progress.keys, :vendors
    assert_includes progress.keys, :sales_history
  end

  test "all_progress returns sync data for each type" do
    progress = @service.all_progress

    progress.each do |sync_type, data|
      assert_instance_of Hash, data
      assert_includes data.keys, :sync_percent
    end
  end

  test "memoizes sync data to avoid multiple calls" do
    @service.progress_for(:products)
    first_result = @service.instance_variable_get(:@products_progress)

    @service.progress_for(:products)
    second_result = @service.instance_variable_get(:@products_progress)

    assert_same first_result, second_result
  end
end
