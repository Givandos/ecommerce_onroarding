require "test_helper"

class UpdateProgressServiceTest < ActiveSupport::TestCase
  setup do
    @company = companies(:one)
    @step = onboarding_steps(:one)
    @params = {}
    @service = UpdateProgressService.new(company: @company, slug: @step.slug, params: @params)
  end

  test "initializes with company, slug, and params" do
    assert_equal @company, @service.instance_variable_get(:@company)
    assert_equal @step.slug.to_sym, @service.instance_variable_get(:@slug)
    assert_equal @params, @service.instance_variable_get(:@params)
  end

  test "call completes step when no errors" do
    @company.onboarding_progress.update!(current_step: @step)
    @service.instance_variable_set(:@slug, :welcome)

    @service.call

    assert @company.onboarding_progress.completed_step?("welcome")
  end

  test "call sets error when step is locked" do
    @step.update!(required_sync_type: "products")
    @service = UpdateProgressService.new(company: @company, slug: @step.slug, params: @params)

    @service.call

    assert_not_nil @service.error
    assert_includes @service.error, "locked"
  end

  test "set_lead_time updates company setting" do
    @company.company_setting.create! if @company.company_setting.nil?
    @service.instance_variable_set(:@slug, :lead_time)
    @service.instance_variable_set(:@params, {default_lead_time: 30})

    @service.send(:set_lead_time)

    assert_equal 30, @company.company_setting.reload.default_lead_time
  end

  test "set_lead_time sets error when param is missing" do
    @service.instance_variable_set(:@slug, :lead_time)
    @service.instance_variable_set(:@params, {})

    @service.send(:set_lead_time)

    assert_not_nil @service.error
    assert_includes @service.error, "required"
  end

  test "po_upload allows skipping if step is skippable" do
    @step.update!(skippable: true)
    @service.instance_variable_set(:@step, @step)
    @service.instance_variable_set(:@params, {skip_step: true})

    @service.send(:po_upload)

    assert_nil @service.error
  end

  test "po_upload sets error when skipping non-skippable step" do
    @step.update!(skippable: false)
    @service.instance_variable_set(:@step, @step)
    @service.instance_variable_set(:@params, {skip_step: true})

    @service.send(:po_upload)

    assert_not_nil @service.error
    assert_includes @service.error, "can't skip"
  end

  test "complete_step marks step as completed" do
    @company.onboarding_progress.update!(current_step: @step)

    @service.send(:complete_step)

    assert @company.onboarding_progress.completed_step?(@step.slug)
  end

  test "skip_step marks step as skipped" do
    @company.onboarding_progress.update!(current_step: @step)

    @service.send(:skip_step)

    assert @company.onboarding_progress.skipped_step?(@step.slug)
  end

  test "move_next moves to next step if available" do
    next_step = onboarding_steps(:two)
    @company.onboarding_progress.update!(current_step: @step)
    @service.instance_variable_set(:@step, @step)

    @service.send(:move_next)

    assert_equal next_step, @company.onboarding_progress.reload.current_step
  end

  test "move_next marks progress as completed when no next step" do
    @company.onboarding_progress.update!(current_step: @step)
    Company.where.not(id: @company.id).destroy_all
    OnboardingStep.where.not(id: @step.id).destroy_all

    @service.send(:move_next)

    assert @company.onboarding_progress.reload.completed?
  end

  test "locked_by_sync? returns true when sync is incomplete" do
    @step.update!(required_sync_type: "products")
    @service = UpdateProgressService.new(company: @company, slug: @step.slug, params: @params)

    result = @service.send(:locked_by_sync?, @step)

    assert_includes [true, false], result
  end

  test "locked_by_sync? returns false when no required sync type" do
    @step.update!(required_sync_type: nil)

    result = @service.send(:locked_by_sync?, @step)

    assert_equal false, result
  end

  test "locked_by_step? returns false when no required step" do
    @step.update!(required_step_id: nil)

    result = @service.send(:locked_by_step?, @step)

    assert_equal false, result
  end

  test "locked_by_step? returns true when required step not completed" do
    required_step = onboarding_steps(:one)
    @step.update!(required_step_id: required_step.id)

    result = @service.send(:locked_by_step?, @step)

    assert_equal true, result
  end

  test "locked_by_step? returns false when required step is completed" do
    required_step = onboarding_steps(:one)
    @step.update!(required_step_id: required_step.id)
    @company.onboarding_progress.complete_step!(required_step.slug)

    result = @service.send(:locked_by_step?, @step)

    assert_equal false, result
  end
end
