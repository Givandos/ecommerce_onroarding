# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Create User and them Company with settings
industry = Industry.create!(name: "Retail")
company = Company.create!(name: "Demo Company", industry: industry, size: "Medium", location: "Berlin")
company.users.create!(name: "Demo User")
company.create_company_setting!
company.create_onboarding_progress!

puts "Seeded user and company"

# Create Onboarding Steps
steps_data = [
  { name: "Welcome", slug: "welcome", position: 10, required_sync_type: nil, skippable: false },
  { name: "Lead Time", slug: "lead_time", position: 20, required_step_slug: "welcome", required_sync_type: nil, skippable: false },
  { name: "Days of Stock", slug: "days_of_stock", position: 30, required_step_slug: "welcome", required_sync_type: nil, skippable: false },
  { name: "Forecasting", slug: "forecasting", position: 40, required_step_slug: "welcome", required_sync_type: nil, skippable: false },
  { name: "PO Upload", slug: "po_upload", position: 50, required_sync_type: "products" },
  { name: "Suppliers Match", slug: "suppliers_match", position: 60, required_sync_type: "warehouses" },
  { name: "Bundles", slug: "bundles", position: 70, required_step_slug: "suppliers_match", required_sync_type: nil },
  { name: "Integrations", slug: "integrations", position: 80, required_step_slug: "bundles", required_sync_type: nil }
]

steps_data.each do |step_data|
  OnboardingStep.find_or_create_by!(slug: step_data[:slug]) do |step|
    step.name = step_data[:name]
    step.position = step_data[:position]
    step.required_sync_type = step_data[:required_sync_type]
    step.required_step_id = OnboardingStep.find_by(slug: step_data[:required_step_slug])&.id if step_data[:required_step_slug].present?
    step.skippable = step_data[:skippable] if step_data[:skippable].present?
  end
end

puts "Seeded #{OnboardingStep.count} onboarding steps"
