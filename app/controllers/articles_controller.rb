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

    @message = @article.reload.is_read ?  t("article.mark_as_read") :  t("article.mark_as_unread")

    referrer = Rails.application.routes.recognize_path(request.referrer)

    show_content = referrer[:action] == "show" ? true : false

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(@article, partial: "articles/article", locals: { article: @article, message: @message, show_content: show_content })
      end
    end
  end
end
