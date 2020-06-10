# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

require 'csv'

MERCHANT_FILE = Rails.root.join('db', 'merchant_seeds.csv')
puts "Loading raw merchant data from #{MERCHANT_FILE}"

merchant_failures = []
CSV.foreach(MERCHANT_FILE, :headers => true) do |row|
  merchant = Merchant.new
  merchant.name = row['name']
  merchant.uid = row['uid']
  merchant.provider = row['provider']
  merchant.email = row['email']

  successful = merchant.save
  if !successful
    merchant_failures << merchant
    puts "Failed to save merchant: #{merchant.inspect}"
  else
    puts "Created merchant: #{merchant.inspect}"
  end
end

puts "Added #{Merchant.all.length} merchant records"
puts "#{merchant_failures.length} merchant failed to save"


PRODUCT_FILE = Rails.root.join('db', 'products_seeds.csv')
puts "Loading raw media data from #{PRODUCT_FILE}"

product_failures = []
CSV.foreach(PRODUCT_FILE, :headers => true) do |row|
  product = Product.new
  product.id = row['id']
  product.name = row['name']
  product.description= row['description']
  product.price = row['price']
  product.photo_url = row['photo_url']
  product.stock = row['stock']
  product.merchant_id = rand(1..Merchant.all.length)

  successful = product.save
  if !successful
    product_failures << product
    puts "Failed to save product: #{product.inspect}"
  else
    puts "Created product: #{product.inspect}"
  end
end

puts "Added #{Product.all.length} media records"
puts "#{product_failures.length} media failed to save"



CUSTOMER_FILE = Rails.root.join('db', 'customer_seeds.csv')
puts "Loading raw customer data from #{CUSTOMER_FILE}"

order_failures = []
CSV.foreach(CUSTOMER_FILE, :headers => true) do |row|
  order = Order.new
  # order.id = row['id']
  order.buyer_name = row['buyer_name']
  order.email_address = row['email_address']
  order.mail_address = row['mail_address']
  order.zip_code = row['zip_code']
  order.cc_num = row['cc_num']
  order.cc_exp = row['cc_exp']

  successful = order.save
  if !successful
    order_failures << order
    puts "Failed to save order: #{order.inspect}"
  else
    puts "Created order: #{order.inspect}"
  end
end

puts "Added #{Order.all.length} order records"
puts "#{order_failures.length} order failed to save"



puts "Generating random OrderItems"

10.times do |i|
  current_order = rand(1..Order.all.length)
  order = Order.find_by(id: current_order)

  item_params = {quantity: rand(1..5),
                 product_id: rand(1..Product.all.length),
                 order_id: current_order}

  new_order_item = OrderItem.create(item_params)
  order.order_items << new_order_item
end

puts "Added #{OrderItem.all.length} order_item records"