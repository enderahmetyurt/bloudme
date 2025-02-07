module ArticlesHelper
  def article_action(article)
    if article.youtube?
      t("article.watch_original")
    else
      t("article.read_original")
    end
  end
end
