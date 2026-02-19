class CompanySetting < ApplicationRecord
  belongs_to :company

  validates :default_lead_time, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :days_of_stock, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :forecasting_days, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
end
