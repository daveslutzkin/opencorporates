require './nz_scraper.rb'
require 'vcr'

describe NzScraper do
  describe '.each_search' do
    it "yields for each of the 1296 permutations" do
      expect{ |b| NzScraper.send(:each_search, &b) }.to yield_control.exactly(1296).times
    end
  end

  before(:all) do
    VCR.configure do |c|
      c.cassette_library_dir = 'fixtures/vcr_cassettes'
      c.hook_into :webmock
    end
  end

  describe '.each_result' do
    around(:each) do |test|
      VCR.use_cassette('aa') do
        test.run
      end
    end

    before(:each) do
      allow(NzScraper).to receive(:each_search).and_yield('aa')
    end

    it "yields for each row in the 'aa' results" do
      expect(NzScraper.each_result.count).to eq(10)
    end

    describe "for the first row" do
      subject { NzScraper.each_result.first }

      it "yields the right name for the first row" do
        expect(subject[0]).to eq('AA CURRENCY EXCHANGE LIMITED')
      end
      it "yields the right number for the first row" do
        expect(subject[1]).to eq('FSP412806')
      end
      it "yields the right trading name for the first row" do
        expect(subject[2]).to eq('Aa Currency Exchange Limited')
      end
      it "yields the right address for the first row" do
        expect(subject[3]).to eq('891 Mt Eden Road Mt Eden Auckland')
      end
      it "yields the right registration date for the first row" do
        expect(subject[4]).to eq(Date.new(2014, 11, 21))
      end
      it "yields the right URL for the first row" do
        expect(subject[5]).to eq("http://www.business.govt.nz/fsp/app/ui/fsp/version/searchSummaryCompanyFSP/FSP412806.do")
      end
    end

    describe "for the last row" do
      subject { NzScraper.each_result.to_a.last }

      it "yields the right name for the last row" do
        expect(subject[0]).to eq('QUICK FINANCE LIMITED')
      end
      it "yields the right number for the last row" do
        expect(subject[1]).to eq('FSP335746')
      end
      it "yields the right trading name for the last row" do
        expect(subject[2]).to eq('Aabaas Finance')
      end
      it "yields the right address for the last row" do
        expect(subject[3]).to eq('254 Innes Road Saint Albans Christchurch')
      end
      it "yields the right registration date for the last row" do
        expect(subject[4]).to eq(Date.new(2013, 12, 17))
      end
      it "yields the right URL for the last row" do
        expect(subject[5]).to eq("http://www.business.govt.nz/fsp/app/ui/fsp/version/searchSummaryCompanyFSP/FSP335746.do")
      end
    end
  end
end
