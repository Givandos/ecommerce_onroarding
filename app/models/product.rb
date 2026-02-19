class Product < ApplicationRecord
  belongs_to :company
  belongs_to :category
  has_many :sales_histories, dependent: :destroy

  validates :name, presence: true
end
