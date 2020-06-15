class Category < ApplicationRecord
  has_and_belongs_to_many :products

  validates :category, presence: true, uniqueness: true
end
