class FeedsController < ApplicationController
  def index
    @feeds = Current.user.feeds
  end

  def new
    @feed = Current.user.feeds.build
  end

  def create
    parsed_feed = RssParserService.fetch_and_parse(feed_params[:url])

    if parsed_feed
      @feed = Current.user.feeds.create(
        url: feed_params[:url],
        title: parsed_feed[:title],
        description: parsed_feed[:description]
      )
      parsed_feed[:entries].each do |entry|
        @feed.articles.create(entry)
      end

      redirect_to articles_path, notice: "Feed added successfully."
    else
      redirect_to new_feed_path, alert: t("feeds.create.error")
    end
  end

  def show
    @feed = Current.user.feeds.find(params[:id])
    @articles = @feed.articles.recent
  end

  private

  def feed_params
    params.require(:feed).permit(:url)
  end
end
