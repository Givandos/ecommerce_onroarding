class ProductFetcher
  attr_reader :company

  def initialize(company)
    @company = company
  end

  def progress
    # Simulate sync progress based on previous steps progress
    # In a real scenario, this would track actual sync progress

    # We expect 4 completed steps that mean 25% progress on each
    expected_keys = %w[welcome lead_time days_of_stock forecasting]
    progress = company.onboarding_progress
    percent = (progress.completed_steps.keys & expected_keys).size * 25

    {
      count: 100,
      sync_percent: percent
    }
  end
end
