require 'faraday'
require 'nokogiri'

class NzScraper

  def self.each_result
    return to_enum(__method__) unless block_given?
    each_search do |search_text|
      search_results_url = "http://www.business.govt.nz/fsp/app/ui/fsp/record/liveSearchFsp.do?action=search&fspVersion=&fspEntityIdentifier=&adv=true&svcCode=&pageNum=1&pageSize=200&sort=nameAsc&nameNumber=#{search_text}&fspTypes=COY&searchScope=current&financialServices=ALL&fspStatuses=registered&address=&scrollTop=30"
      html = Nokogiri::HTML(Faraday.new.get(search_results_url).body)
      html.css('.uiresult').each do |result_row|
        (_, name, number) = /^(.*) \((.*)\)$/.match(result_row.at_css('.resultName').text.strip).to_a

        trading_names_node = result_row.at_css('.resultTradingName > span:last-child')
        trading_names = trading_names_node.text if trading_names_node

        address = result_row.at_css('.resultAddress').text.strip

        registered_date = Date.parse(result_row.at_css('.resultRegisteredDate').text)

        yield name, number, trading_names, address, registered_date, "http://www.business.govt.nz/fsp/app/ui/fsp/version/searchSummaryCompanyFSP/#{number}.do"
      end
    end
  end

  private

    def self.each_search
      [*('a'..'z'), *('0'..'9')].repeated_permutation(2).each do |x,y|
        yield x + y
      end 
    end
end
