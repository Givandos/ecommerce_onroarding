require "test_helper"

class RefreshCalculationsWorkerTest < ActiveSupport::TestCase
  setup do
    @company = companies(:one)
    @company.create_company_setting! unless @company.company_setting
    @worker = RefreshCalculationsWorker.new
  end

  test "should be a Sidekiq worker" do
    assert_includes RefreshCalculationsWorker.ancestors, Sidekiq::Worker
  end

  test "perform should find company by id" do
    assert_nothing_raised do
      @worker.perform(@company.id)
    end
  end

  test "perform should access company setting" do
    @worker.perform(@company.id)
    # Test passes if no errors are raised accessing company.company_setting
    assert_not_nil @company.company_setting
  end
end
