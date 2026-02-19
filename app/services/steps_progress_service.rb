class StepsProgressService
  attr_reader :steps_data, :progress

  def initialize(company, sync_service:)
    @company = company
    @progress = company.onboarding_progress
    @sync_service = sync_service || SyncStatusService.new(company)
    @all_steps = OnboardingStep.ordered
    initialize_progress
  end
  def call
    @steps_data = @all_steps.map.with_index do |step, index|
      step_status(step)

      {
        id: step.id,
        name: step.name,
        slug: step.slug,
        position: index + 1,
        status: step_status(step),
        required_step_id: step.required_step_id,
        required_sync_type: step.required_sync_type,
        skippable: step.skippable
      }
    end
  end

  private

  def initialize_progress
    # Initialize current step if not set
    return if @progress.current_step_id.present? && !@progress.not_started?

    first_step = @all_steps.first
    @progress.move_to_step!(first_step) if first_step
  end

  def step_status(step)
    return "active" if @progress.current_step_id == step.id
    return "completed" if @progress.completed_step?(step.slug)
    return "skipped" if @progress.skipped_step?(step.slug)
    return "locked" if is_locked?(step)

    "pending"
  end

  def is_locked?(step)
    locked_by_sync?(step) || locked_by_step?(step)
  end

  def locked_by_sync?(step)
    return false if step.required_sync_type.blank?

    @sync_service.progress_for(step.required_sync_type) < 100
  end

  def locked_by_step?(step)
    return false if step.required_step_id.blank?

    required_step_slug = @all_steps.find_by(id: step.required_step_id)&.slug
    return false unless required_step_slug

    !(@progress.completed_step?(required_step_slug) || @progress.skipped_step?(required_step_slug))
  end
end
