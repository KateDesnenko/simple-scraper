RSpec.describe Simple::Scraper do
  describe 'Scraper' do
    let(:scraper) do
      Simple::Scraper::Parser.new(
        title: { selector: "//*[@class='title']", handler: ->(els) { els.first.text } },
        summary: { selector: "//*[@class='the-class-not-exists']", handler: ->(els) { els.first.text }, default: 'Ruby' },
        desc: { selector: "//*[@class='the-class-not-exists']", handler: ->(els) { els.first.text } }
      )
    end

    it 'has a version number' do
      expect(Simple::Scraper::VERSION).not_to be nil
    end

    it 'performs basic web page scraping' do
      result_array = nil

      VCR.use_cassette('fcmriya') do
        result_array = scraper.parse(
          [
            'https://fcmriya.com/',
            'https://fcmriya.com/',
            'https://fcmriya.com/',
            'https://fcmriya.com/',
            'https://fcmriya.com/',
            'invalid.url.com'
          ]
        )
      end

      expect(result_array.first[:title]).to eq 'Запрошуємо на міжнародний дитячий футбольний турнір'
      expect(result_array.first[:summary]).to eq 'Ruby'
      expect(result_array.first[:desc]).to eq nil
      expect(result_array.size).to eq 5
    end

    it 'performs web page scraping for single url' do
      result_array = nil
      VCR.use_cassette('fcmriya') do
        result_array = scraper.parse('https://fcmriya.com/')
      end

      expect(result_array.size).to eq 1
    end
  end

  describe 'Configuration' do
    it 'specifies proxy' do
      Simple::Scraper.configure do |config|
        config.proxy_addr = 'proxy.something.com'
        config.proxy_port = 80
        config.proxy_user = 'user:'
        config.proxy_pass = 'password'
      end

      expect(Simple::Scraper.configuration.proxy_addr).to eq 'proxy.something.com'
      expect(Simple::Scraper.configuration.proxy_port).to eq 80
      expect(Simple::Scraper.configuration.proxy_user).to eq 'user:'
      expect(Simple::Scraper.configuration.proxy_pass).to eq 'password'
    end

    it 'specifies number of threads' do
      Simple::Scraper.configure do |config|
        config.number_of_threads = 20
      end

      expect(Simple::Scraper.configuration.number_of_threads).to eq 20
    end

    it 'adds logger' do
      Simple::Scraper.configure do |config|
        config.logger = Logger.new(STDOUT)
      end

      expect(Simple::Scraper.configuration.logger).to be_an_instance_of Logger
    end

    it 'resets to defaults' do
      Simple::Scraper.configure do |config|
        config.number_of_threads = 20
        config.logger = Logger.new(STDOUT)
      end

      Simple::Scraper.reset

      expect(Simple::Scraper.configuration.logger).to eq nil
      expect(Simple::Scraper.configuration.number_of_threads).to eq 1 # => since default is set to 1
    end
  end
end
