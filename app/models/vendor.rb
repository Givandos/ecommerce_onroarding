class Vendor < ApplicationRecord
  belongs_to :company
  has_many :products, dependent: :destroy, foreign_key: :supplier_id

  validates :name, presence: true
end
