class OnboardingStatusService
  attr_reader :status_data

  def initialize(company)
    @company = company
  end

  def call
    sync_service = SyncStatusService.new(@company)
    steps_progress_service = StepsProgressService.new(@company, sync_service: sync_service)
    steps_progress_service.call
    progress = steps_progress_service.progress

    @status_data = {
      current_step: progress.current_step ? {
        id: progress.current_step.id,
        name: progress.current_step.name,
        slug: progress.current_step.slug
      } : nil,
      overall_status: progress.status,
      steps: steps_progress_service.steps_data,
      sync_progress: sync_service.all_progress
    }
  end
end
