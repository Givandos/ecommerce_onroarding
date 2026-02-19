require "test_helper"

class StepsProgressServiceTest < ActiveSupport::TestCase
  setup do
    @company = companies(:one)
    Company.where.not(id: @company.id).destroy_all
    @sync_service = SyncStatusService.new(@company)
    @service = StepsProgressService.new(@company, sync_service: @sync_service)
  end

  test "initializes with company and sync service" do
    assert_equal @company, @service.instance_variable_get(:@company)
    assert_equal @sync_service, @service.instance_variable_get(:@sync_service)
  end

  test "initializes progress if not set" do
    progress = @company.onboarding_progress
    progress.update!(current_step: nil, status: :not_started)

    service = StepsProgressService.new(@company, sync_service: @sync_service)

    assert_not_nil service.progress.current_step
  end

  test "call returns steps data array" do
    @service.call

    assert_instance_of Array, @service.steps_data
  end

  test "steps_data includes all required fields" do
    @service.call

    @service.steps_data.each do |step_data|
      assert_includes step_data.keys, :id
      assert_includes step_data.keys, :name
      assert_includes step_data.keys, :slug
      assert_includes step_data.keys, :position
      assert_includes step_data.keys, :status
      assert_includes step_data.keys, :required_step_id
      assert_includes step_data.keys, :required_sync_type
      assert_includes step_data.keys, :skippable
    end
  end

  test "step_status returns active for current step" do
    step = onboarding_steps(:one)
    @company.onboarding_progress.update!(current_step: step)

    @service.call
    status = @service.send(:step_status, step)

    assert_equal "active", status
  end

  test "step_status returns completed for completed step" do
    step = onboarding_steps(:three)
    @company.onboarding_progress.complete_step!(step.slug)

    @service.call
    status = @service.send(:step_status, step)

    assert_equal "completed", status
    assert_not_equal step.id, @company.onboarding_progress.current_step_id
  end

  test "step_status returns active for completed step if it's active in onboarding_process" do
    step = onboarding_steps(:one)
    @company.onboarding_progress.complete_step!(step.slug)

    @service.call
    status = @service.send(:step_status, step)

    assert_equal "active", status
    assert_equal step.id, @company.onboarding_progress.current_step_id
  end

  test "step_status returns skipped for skipped step" do
    step = onboarding_steps(:three)
    @company.onboarding_progress.skip_step!(step.slug)

    @service.call
    status = @service.send(:step_status, step)

    assert_equal "skipped", status
    assert_not_equal step.id, @company.onboarding_progress.current_step_id
  end

  test "step_status returns active for skipped step if it's active in onboarding_process" do
    step = onboarding_steps(:one)
    @company.onboarding_progress.skip_step!(step.slug)

    @service.call
    status = @service.send(:step_status, step)

    assert_equal "active", status
    assert_equal step.id, @company.onboarding_progress.current_step_id
  end

  test "step_status returns pending for pending step" do
    step = onboarding_steps(:two)

    @service.call
    status = @service.send(:step_status, step)

    assert_includes ["pending", "locked"], status
  end
end
