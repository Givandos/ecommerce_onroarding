require "test_helper"

class VendorFetcherTest < ActiveSupport::TestCase
  setup do
    @company = companies(:one)
    @fetcher = VendorFetcher.new(@company)
  end

  test "initializes with company" do
    assert_equal @company, @fetcher.company
  end

  test "progress returns hash with count and sync_percent" do
    result = @fetcher.progress

    assert_instance_of Hash, result
    assert_includes result.keys, :count
    assert_includes result.keys, :sync_percent
  end

  test "progress returns fixed values" do
    result = @fetcher.progress

    assert_equal 7, result[:count]
    assert_equal 33, result[:sync_percent]
  end
end
