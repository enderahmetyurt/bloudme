class FeedsController < ApplicationController
  def index
    @feeds = current_user.feeds
  end

  def new
    @feed = Feed.new
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
      redirect_to new_feed_path, alert: "Failed to parse feed."
    end
  end

  def show
    @feed = current_user.feeds.find(params[:id])
    @articles = @feed.articles
  end

  private

  def feed_params
    params.require(:feed).permit(:url)
  end
end
