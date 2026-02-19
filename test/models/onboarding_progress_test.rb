require "test_helper"

class OnboardingProgressTest < ActiveSupport::TestCase
  test "should belong to company" do
    assert_respond_to OnboardingProgress.new, :company
  end

  test "should belong to current_step" do
    assert_respond_to OnboardingProgress.new, :current_step
  end

  test "should have status enum" do
    assert_equal({"not_started" => 1, "in_progress" => 2, "completed" => 3}, OnboardingProgress.statuses)
  end

  test "completed_step? returns true when step is completed" do
    progress = OnboardingProgress.new(completed_steps: {"welcome" => "completed"})
    assert progress.completed_step?("welcome")
  end

  test "completed_step? returns false when step is not completed" do
    progress = OnboardingProgress.new(completed_steps: {})
    assert_not progress.completed_step?("welcome")
  end

  test "skipped_step? returns true when step is skipped" do
    progress = OnboardingProgress.new(completed_steps: {"welcome" => "skipped"})
    assert progress.skipped_step?("welcome")
  end

  test "skipped_step? returns false when step is not skipped" do
    progress = OnboardingProgress.new(completed_steps: {})
    assert_not progress.skipped_step?("welcome")
  end

  test "complete_step! marks step as completed" do
    progress = OnboardingProgress.create!(status: :not_started, company: companies(:one))
    progress.complete_step!("welcome")
    assert_equal "completed", progress.completed_steps["welcome"]
  end

  test "skip_step! marks step as skipped" do
    progress = OnboardingProgress.create!(status: :not_started, company: companies(:one))
    progress.skip_step!("welcome")
    assert_equal "skipped", progress.completed_steps["welcome"]
  end

  test "move_to_step! updates current_step and status" do
    progress = OnboardingProgress.create!(status: :not_started, company: companies(:one))
    step = onboarding_steps(:one)
    progress.move_to_step!(step)
    assert_equal step, progress.current_step
    assert progress.in_progress?
  end
end
