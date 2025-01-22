class ArticlesController < ApplicationController
  def index
    @articles =  Article.joins(feed: :user).where(feeds: { user: Current.user }).recent
    @feed = Feed.new
  end

  def show
    @article = Article.find(params[:id])
  end

  def update_read
    @article = Article.find(params[:id])
    @article.is_read = !@article.is_read
    @article.save

    message = @article.reload.is_read ?  t("article.mark_as_read") :  t("article.mark_as_unread")

    render turbo_stream: turbo_stream.replace(
      @article, partial: "articles/article", locals: { article: @article, notice: message }
    ), notice: "aa"
  end
end
