require "csv"

CATEGORY_FILE = Rails.root.join("db", "category_seeds.csv")
puts "Loading raw category data from #{CATEGORY_FILE}"

category_failures = []
CSV.foreach(CATEGORY_FILE, :headers => true) do |row|
  category = Category.new
  category.category = row["category"]

  successful = category.save
  if !successful
    category_failures << category
    puts "Failed to save category: #{category.inspect}"
  else
    puts "Created category: #{category.inspect}"
  end
end

puts "Added #{Category.all.length} category records"
puts "#{category_failures.length} category failed to save"

###########################################################
###########################################################

MERCHANT_FILE = Rails.root.join("db", "merchant_seeds.csv")
puts "Loading raw merchant data from #{MERCHANT_FILE}"

merchant_failures = []
CSV.foreach(MERCHANT_FILE, :headers => true) do |row|
  merchant = Merchant.new
  merchant.name = row["name"]
  merchant.uid = row["uid"]
  merchant.provider = row["provider"]
  merchant.email = row["email"]
  merchant.avatar = row["avatar"]

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

###########################################################
###########################################################

PRODUCT_FILE = Rails.root.join("db", "products_seeds.csv")
puts "Loading raw product data from #{PRODUCT_FILE}"

product_failures = []
CSV.foreach(PRODUCT_FILE, :headers => true) do |row|
  product = Product.new
  product.name = row["name"]
  product.description = row["description"]
  product.price = row["price"]
  product.photo_url = row["photo_url"]
  product.stock = row["stock"]
  product.tags = row["tags"]
  product.merchant_id = rand(1..Merchant.all.length)

  successful = product.save
  if !successful
    product_failures << product
    puts "Failed to save product: #{product.inspect}"
  else
    puts "Created product: #{product.inspect}"
    row["tags"].split(":").each do |category|
      binding.pry if category.nil? || Category.find_by(category: category.strip).nil?
      product.categories << Category.find_by(category: category.strip)
    end
  end
end

puts "Added #{Product.all.length} product records"
puts "#{product_failures.length} products failed to save"

###########################################################
###########################################################

REVIEW_FILE = Rails.root.join("db", "review_seeds.csv")
puts "Loading raw review data from #{REVIEW_FILE}"

review_failures = []
CSV.foreach(REVIEW_FILE, :headers => true) do |row|
  review = Review.new
  review.rating = row["rating"]
  review.review_text = row["review_text"]
  review.product_id = rand(1..Product.all.length)

  successful = review.save
  if !successful
    review_failures << review
    puts "Failed to save review: #{review.inspect}"
  else
    puts "Created review: #{review.inspect}"
  end
end

puts "Added #{Review.all.length} review records"
puts "#{review_failures.length} reviews failed to save"

###########################################################
###########################################################

CUSTOMER_FILE = Rails.root.join("db", "customer_seeds.csv")
puts "Loading raw customer data from #{CUSTOMER_FILE}"

order_failures = []
CSV.foreach(CUSTOMER_FILE, :headers => true) do |row|
  order = Order.new
  order.buyer_name = row["buyer_name"]
  order.email_address = row["email_address"]
  order.mail_address = row["mail_address"]
  order.zip_code = row["zip_code"]
  order.cc_num = "************" + row["cc_num"]
  order.cc_exp = row["cc_exp"]
  order.cc_cvv = "***"

  rand(1..5).times do |i|
    order.order_items << OrderItem.new(
      product_id: rand(1..Product.all.length),
      quantity: i,
    )
  end

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
puts "Added #{OrderItem.all.length} order_item records"
