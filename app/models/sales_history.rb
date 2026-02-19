class SalesHistory < ApplicationRecord
  belongs_to :company
  belongs_to :product

  validates :quantity, :date, presence: true
end
