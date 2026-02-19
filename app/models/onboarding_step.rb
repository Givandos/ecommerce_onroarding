class OnboardingStep < ApplicationRecord
  has_many :onboarding_progresses, foreign_key: :current_step_id

  validates :name, :slug, :position, presence: true
  validates :slug, uniqueness: true
  validates :skippable, inclusion: { in: [true, false] }
  validates :required_sync_type, inclusion: { in: %w[products sales_history warehouses vendors] }

  scope :ordered, -> { order(:position) }
end
