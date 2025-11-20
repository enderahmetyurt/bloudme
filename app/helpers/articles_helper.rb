module ArticlesHelper
  def article_action(article)
    if article.youtube?
      t("article.watch_original")
    else
      t("article.read_original")
    end
  end

  def safe_link_to(text, url, **options)
    uri = URI.parse(url)
    return unless uri.scheme.in?(%w[http https])
    link_to(text, url, **options)
  rescue URI::InvalidURIError
    nil
  end

  def share_on_x_url(article)
    text = "Check out: #{article.title} #{article.link}"
    "https://x.com/intent/tweet?text=#{ERB::Util.url_encode(text)}"
  end

  def share_on_bsky_url(article)
    text = "Check out: #{article.title} #{article.link}"
    "https://bsky.app/intent/compose?text=#{ERB::Util.url_encode(text)}"
  end

  def share_on_linkedin_url(article)
    "https://www.linkedin.com/sharing/share-offsite/?url=#{ERB::Util.url_encode(article.link)}"
  end
end
