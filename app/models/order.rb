class Order < ApplicationRecord
  has_many :order_items

  validates :buyer_name, presence: true
  validates :email_address, presence: true
  validates :mail_address, presence: true
  validates :zip_code, presence: true, numericality: true, length: {is: 5}
  validates :cc_num, presence: true, numericality: true
  validates :cc_exp, presence: true, numericality: true
end
