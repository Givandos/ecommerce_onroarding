require "test_helper"

class OnboardingStepTest < ActiveSupport::TestCase
  test "should have many onboarding_progresses" do
    assert_respond_to OnboardingStep.new, :onboarding_progresses
  end

  test "should validate presence of name" do
    step = OnboardingStep.new
    assert_not step.valid?
    assert_includes step.errors[:name], "can't be blank"
  end

  test "should validate presence of slug" do
    step = OnboardingStep.new
    assert_not step.valid?
    assert_includes step.errors[:slug], "can't be blank"
  end

  test "should validate presence of position" do
    step = OnboardingStep.new
    assert_not step.valid?
    assert_includes step.errors[:position], "can't be blank"
  end

  test "should validate uniqueness of slug" do
    OnboardingStep.create!(name: "Test", slug: "test", position: 1, skippable: false)
    duplicate = OnboardingStep.new(name: "Test 2", slug: "test", position: 2, skippable: false)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:slug], "has already been taken"
  end

  test "should validate inclusion of skippable" do
    step = OnboardingStep.new(name: "Test", slug: "test", position: 1, skippable: nil)
    assert_not step.valid?
    assert_includes step.errors[:skippable], "is not included in the list"
  end

  test "should validate inclusion of required_sync_type" do
    step = OnboardingStep.new(name: "Test", slug: "test", position: 1, skippable: false, required_sync_type: "invalid")
    assert_not step.valid?
    assert_includes step.errors[:required_sync_type], "is not included in the list"
  end

  test "ordered scope returns steps in position order" do
    step1 = OnboardingStep.create!(name: "First", slug: "first", position: 2,)
    step2 = OnboardingStep.create!(name: "Second", slug: "second", position: 1)
    assert_equal [step2, step1], OnboardingStep.where(id: [step1, step2]).ordered.to_a
  end
end
