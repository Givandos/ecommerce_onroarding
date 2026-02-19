require "test_helper"

class SalesHistoryFetcherTest < ActiveSupport::TestCase
  setup do
    @company = companies(:one)
    @fetcher = SalesHistoryFetcher.new(@company)
  end

  test "initializes with company" do
    assert_equal @company, @fetcher.company
  end

  test "progress returns hash with products_count and sync_percent" do
    result = @fetcher.progress

    assert_instance_of Hash, result
    assert_includes result.keys, :products_count
    assert_includes result.keys, :sync_percent
  end

  test "progress returns fixed values" do
    result = @fetcher.progress

    assert_equal 236, result[:products_count]
    assert_equal 0, result[:sync_percent]
  end
end
