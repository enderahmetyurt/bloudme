require "uri"
require "open-uri"
require "nokogiri"
require "feedbag"

class SiteMetadataFetcher
  def initialize(url)
    @url = url
  end

  def call
    return unless feed_url

    {
      feed_url: feed_url,
      site_url: site_url,
      favicon:  favicon
    }
  end

  private

  attr_reader :url

  def feed_url
    @feed_url ||= Feedbag.find(url)&.first
  rescue
    nil
  end

  def site_url
    @site_url ||= begin
      uri = URI.parse(feed_url)
      "#{uri.scheme}://#{uri.host}"
    rescue
      nil
    end
  end

  def favicon
    html = URI.open(site_url, "User-Agent" => "Rails").read
    doc  = Nokogiri::HTML(html)

    icon = doc.at_css("link[rel~='icon'], link[rel='shortcut icon']")
    icon ? URI.join(site_url, icon["href"]).to_s : nil
  rescue
    nil
  end
end
