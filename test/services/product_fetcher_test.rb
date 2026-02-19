require "test_helper"

class ProductFetcherTest < ActiveSupport::TestCase
  setup do
    @company = companies(:one)
    @fetcher = ProductFetcher.new(@company)
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

  test "progress calculates percent based on completed steps" do
    progress = @company.onboarding_progress
    progress.complete_step!("welcome")
    progress.complete_step!("lead_time")

    result = @fetcher.progress

    assert_equal 50, result[:sync_percent]
  end

  test "progress returns 0 when no expected steps completed" do
    result = @fetcher.progress

    assert_equal 0, result[:sync_percent]
  end

  test "progress returns 100 when all expected steps completed" do
    progress = @company.onboarding_progress
    progress.complete_step!("welcome")
    progress.complete_step!("lead_time")
    progress.complete_step!("days_of_stock")
    progress.complete_step!("forecasting")

    result = @fetcher.progress

    assert_equal 100, result[:sync_percent]
  end

  test "progress returns count" do
    result = @fetcher.progress

    assert_equal 100, result[:count]
  end
end
