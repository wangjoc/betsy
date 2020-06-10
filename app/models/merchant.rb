class Merchant < ApplicationRecord
  has_many :products

  validates :username, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true
  validates_format_of :email, :with => /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/  
  
end

