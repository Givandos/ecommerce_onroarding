class Company < ApplicationRecord
  belongs_to :industry
  has_one :onboarding_progress, dependent: :destroy
  has_one :company_setting, dependent: :destroy
  has_many :users, dependent: :destroy
  has_many :products, dependent: :destroy
  has_many :warehouses, dependent: :destroy
  has_many :vendors, dependent: :destroy
  has_many :sales_histories, dependent: :destroy
end
