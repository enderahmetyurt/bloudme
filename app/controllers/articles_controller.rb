class ArticlesController < ApplicationController
  def index
    @articles =  Article.joins(feed: :user).where(feeds: { user: Current.user })
    @feed = Feed.new
  end

  def show
    @article = Article.find(params[:id])
  end
end
