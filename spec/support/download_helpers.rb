module System
  module DownloadHelpers
    TIMEOUT = 10
    PATH = Rails.root.join("tmp/capybara")

    def downloads
      Dir[PATH.join("*")].reject { |f| File.directory?(f) }
    end

    def download
      downloads.first
    end

    def download_content
      wait_for_download
      File.read(download)
    end

    # Header names are case-insensitive, but the driver returns them as the
    # server sent them, and Puma 7+ and Rack 3 send them lowercase.
    def response_header(name)
      page.response_headers.transform_keys(&:downcase).fetch(name.downcase)
    end

    def wait_for_download
      Timeout.timeout(TIMEOUT, Timeout::Error) { sleep 0.1 until downloaded? }
    end

    def downloaded?
      !downloading? && downloads.any?
    end

    def downloading?
      downloads.grep(/\.crdownload$/).any?
    end

    def clear_downloads
      FileUtils.rm_f(downloads)
    end
  end
end

RSpec.configure do |config|
  config.include System::DownloadHelpers, type: :system

  config.around(:each, type: :system, download: ->(v) { v }) do |example|
    clear_downloads
    example.run
    clear_downloads
  end
end
