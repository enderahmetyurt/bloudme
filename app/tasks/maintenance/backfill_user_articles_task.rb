module Maintenance
  class BackfillUserArticlesTask < MaintenanceTasks::Task
    def collection
      Article.includes(:feed).all
    end

    def process(article)
      UserArticle.find_or_create_by!(user_id: article.feed.user_id, article_id: article.id) do |ua|
        ua.is_read = article.is_read
      end
    rescue ActiveRecord::RecordNotUnique
      # race condition safe
    end

    def count
      Article.count
    end
  end
end
