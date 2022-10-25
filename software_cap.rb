require 'date'
require 'active_support/all'

authors = %w[
  TMcMeans
  bhoggard
  damassi
  dzucconi
  jonallured
  laurabeth
  pam-
]
year = '2022'
month_numbers = %w[07 08 09]

urls = authors.product(month_numbers).map do |author, month_number|
  start_date = Date.parse("#{year}-#{month_number}-01")
  stop_date = start_date.end_of_month

  url = "https://github.com/search?l=&type=Issues&s=created&o=asc&q=author%3A#{author}+org%3Aartsy+created%3A#{start_date}..#{stop_date}"
  url
end

puts urls
