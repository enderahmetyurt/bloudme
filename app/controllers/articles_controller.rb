class ArticlesController < ApplicationController
  def index
    redirect_to new_feed_path if Current.user.feeds.empty?

    @feeds = Current.user.feeds.recent

    read_param = ActiveModel::Type::Boolean.new.cast(params[:read]) || false
    @articles = Article.by_current_user(Current.user)
                       .where(is_read: read_param)
                       .includes(:feed, :bookmarks)

    if params[:feed_id].present?
      @articles = @articles.where(feed_id: params[:feed_id])
    end

    @articles = @articles.recent.page(params[:page])
  end

  def show
    @article = Article.includes(:feed, :bookmarks).find(params[:id])
    @article.update(is_read: true)
  end

  def search
    @query = params[:query]
    @articles = Article
      .by_current_user(Current.user)
      .search(@query)
      .includes(:feed, :bookmarks)
      .recent
  end

  def update_read
    @article = Article.find(params[:id])
    @article.update(is_read: ActiveModel::Type::Boolean.new.cast(params[:article][:read]))

    respond_to do |format|
      format.turbo_stream do
        render(
          turbo_stream: [
            turbo_stream.remove("#{helpers.dom_id(@article)}_container"),
            turbo_stream.update("unread", partial: "articles/unread_count", locals: { count: Article.by_current_user(Current.user).unread.count }),
            turbo_stream.update("read", partial: "articles/read_count", locals: { count: Article.by_current_user(Current.user).read.count })
          ])
      end
      format.html { redirect_to articles_path, notice: "Updated todo status." }
    end
  end

  def update_bookmark
    @article = Article.find(params[:id])

    if ActiveModel::Type::Boolean.new.cast(params[:article][:bookmarked])
      Bookmark.create(article: @article, user: Current.user)
    else
      Bookmark.find_by(article: @article, user: Current.user).destroy
    end

    respond_to do |format|
      format.turbo_stream do
        if request.referrer.include?("bookmarks")
          render(
            turbo_stream: [
              turbo_stream.remove("#{helpers.dom_id(@article)}_container")
            ])
        else
          render(
            turbo_stream: [
              turbo_stream.update("#{helpers.dom_id(@article)}_bookmark", partial: "articles/bookmark", locals: { article: @article })
            ])
        end
      end
      format.html { redirect_to bookmarks_path, notice: "Updated bookmarked." }
    end
  end
end
