class RefreshCalculationsWorker
  include Sidekiq::Worker

  def perform(company_id)
    company = Company.find(company_id)
    setting = company.company_setting

    # Implement updating of forecasting days here
    # This worker can trigger (re)generation of AI recommendations

    # Add logs just for debug purposes
    Rails.logger.info "Refreshing calculations for company #{company.name} with forecasting_days: #{setting.forecasting_days}"
  end
end
