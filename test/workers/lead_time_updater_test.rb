require "test_helper"

class LeadTimeUpdaterTest < ActiveSupport::TestCase
  setup do
    @company = companies(:one)
    @company.create_company_setting!(default_lead_time: 10) unless @company.company_setting
    @worker = LeadTimeUpdater.new
  end

  test "should be a Sidekiq worker" do
    assert_includes LeadTimeUpdater.ancestors, Sidekiq::Worker
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
