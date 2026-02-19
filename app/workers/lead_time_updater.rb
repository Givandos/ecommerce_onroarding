class LeadTimeUpdater
  include Sidekiq::Worker

  def perform(company_id)
    company = Company.find(company_id)
    setting = company.company_setting

    # Implement updating of lead time here

    # Add logs just for debug purposes
    Rails.logger.info "Updating lead times for company #{company.name} with default_lead_time: #{setting.default_lead_time}"
  end
end
