class FeedsController < ApplicationController
  def index
    @feeds = Current.user.feeds
  end

  def new
    @feed = Current.user.feeds.build
  end

  def create
    parsed_feed = RssParserService.fetch_and_parse(feed_params[:feed_url])

    if parsed_feed
      @feed = Current.user.feeds.create(
        feed_url: parsed_feed[:feed_url],
        site_url: parsed_feed[:site_url],
        favicon: parsed_feed[:favicon],
        is_podcast: parsed_feed[:is_podcast],
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

  def destroy
    @feed = Current.user.feeds.find(params[:id])
    @feed.destroy

    redirect_to feeds_path, notice: t("feeds.destroy.success")
  end

  private

  def feed_params
    params.require(:feed).permit(:feed_url)
  end
end
