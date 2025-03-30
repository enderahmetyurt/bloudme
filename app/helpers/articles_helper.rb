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
end
