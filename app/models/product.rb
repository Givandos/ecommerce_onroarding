class Product < ApplicationRecord
  belongs_to :company
  belongs_to :category
  belongs_to :supplier, class_name: "Vendor"
  has_many :sales_histories, dependent: :destroy

  validates :name, presence: true
end
