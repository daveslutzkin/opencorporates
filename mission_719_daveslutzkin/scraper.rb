require 'turbotlib'
require_relative './nz_scraper.rb'

NzScraper.each_result do |name, number, _trading_names, _address, _registered_date, search_results_url|
  data = {
    source_url: search_results_url,
    company_name: name,
    number: number,
    sample_date: Date.today,
  }

  puts JSON.dump(data)
end
