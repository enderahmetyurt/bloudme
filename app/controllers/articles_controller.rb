class ArticlesController < ApplicationController
  def index
    @articles = Article
      .by_current_user(Current.user)
      .where(is_read: ActiveModel::Type::Boolean.new.cast(params[:read]) || false)
      .recent
    @feed = Feed.new
  end

  def show
    @article = Article.find(params[:id])
    @article.update(is_read: true)
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
end
