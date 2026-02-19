require "test_helper"

class OnboardingStatusServiceTest < ActiveSupport::TestCase
  setup do
    @company = companies(:one)
    @service = OnboardingStatusService.new(@company)
  end

  test "initializes with company" do
    assert_equal @company, @service.instance_variable_get(:@company)
  end

  test "call returns status data with expected structure" do
    @service.call
    data = @service.status_data

    assert_not_nil data
    assert_includes data.keys, :current_step
    assert_includes data.keys, :overall_status
    assert_includes data.keys, :steps
    assert_includes data.keys, :sync_progress
  end

  test "status_data includes current_step information" do
    step = onboarding_steps(:one)
    @company.onboarding_progress.update!(current_step: step)

    @service.call
    data = @service.status_data

    assert_equal step.id, data[:current_step][:id]
    assert_equal step.name, data[:current_step][:name]
    assert_equal step.slug, data[:current_step][:slug]
  end

  test "status_data includes overall_status" do
    @service.call
    data = @service.status_data

    assert_includes ["not_started", "in_progress", "completed"], data[:overall_status]
  end

  test "status_data includes steps array" do
    @service.call
    data = @service.status_data

    assert_instance_of Array, data[:steps]
  end

  test "status_data includes sync_progress hash" do
    @service.call
    data = @service.status_data

    assert_instance_of Hash, data[:sync_progress]
  end
end
