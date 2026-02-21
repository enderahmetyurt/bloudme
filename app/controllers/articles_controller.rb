class ArticlesController < ApplicationController
  def index
    redirect_to new_feed_path if Current.user.subscribed_feeds.empty?

    @feeds = Current.user.subscribed_feeds.recent

    read_param = ActiveModel::Type::Boolean.new.cast(params[:read]) || false
    @articles = read_param ? Article.read_for_user(Current.user) : Article.unread_for_user(Current.user)
    @articles = @articles.includes(:feed, :bookmarks)

    if params[:feed_id].present?
      @articles = @articles.where(feed_id: params[:feed_id])
    end

    if params[:date].present?
      date = Date.parse(params[:date])
      @articles = @articles.where("DATE(published_at) = ?", date)
    end

    case params[:sort]
    when "latest"
      @articles = @articles.recent
    when "oldest"
      @articles = @articles.order(published_at: :asc)
    when "title_asc"
      @articles = @articles.order(title: :asc)
    when "title_desc"
      @articles = @articles.order(title: :desc)
    else
      @articles = @articles.recent
    end

    @articles = @articles.page(params[:page])
  end

  def show
    @article = Article.includes(:feed, :bookmarks).find(params[:id])
    @article.update(is_read: true)

    UserArticle.find_or_create_by!(user: Current.user, article: @article).update!(is_read: true)
  end

  def search
    @query = params[:query]
    @articles = Article
      .for_user(Current.user)
      .search(@query)
      .includes(:feed, :bookmarks)
      .recent
  end

  def update_read
    @article = Article.find(params[:id])
    read_value = ActiveModel::Type::Boolean.new.cast(params[:article][:read])
    @article.update(is_read: read_value)

    UserArticle.find_or_create_by!(user: Current.user, article: @article).update!(is_read: read_value)

    respond_to do |format|
      format.turbo_stream do
        render(
          turbo_stream: [
            turbo_stream.remove("#{helpers.dom_id(@article)}_container"),
            turbo_stream.update("unread", partial: "articles/unread_count", locals: { count: Article.unread_for_user(Current.user).count }),
            turbo_stream.update("read", partial: "articles/read_count", locals: { count: Article.read_for_user(Current.user).count })
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
