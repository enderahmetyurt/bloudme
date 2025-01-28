class ArticlesController < ApplicationController
  def index
    @articles = Article.joins(feed: :user).where(feeds: { user: Current.user }).unread.recent
    @feed = Feed.new
  end

  def show
    @article = Article.find(params[:id])
  end

  def update_read
    @article = Article.find(params[:id])
    @article.is_read = !@article.is_read
    @article.save

    referrer = Rails.application.routes.recognize_path(request.referrer)

    redirect_feed = referrer[:controller] == "feeds" ? true : false

    if redirect_feed
      redirect_to feed_path(@article.feed)
    else
      redirect_to articles_path
    end
  end
end
