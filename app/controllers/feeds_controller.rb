class FeedsController < ApplicationController
  def index
    redirect_to new_feed_path if Current.user.feeds.empty?

    @feeds = Current.user.feeds
  end

  def new
    @feed = Current.user.feeds.build
  end

  def create
    feed_url = feed_params[:feed_url]
    if feed_url.blank?
      redirect_to new_feed_path, alert: t("feeds.create.url_required")
      return
    end

    parsed_feed = RssParserService.fetch_and_parse(feed_url)

    if parsed_feed
      @feed = Current.user.feeds.create(
        feed_url: parsed_feed[:feed_url],
        site_url: parsed_feed[:site_url],
        favicon: parsed_feed[:favicon] || "default-favicon.png",
        is_podcast: parsed_feed[:is_podcast],
        title: parsed_feed[:title],
        description: parsed_feed[:description]
      )
      parsed_feed[:entries].each do |entry|
        @feed.articles.create(entry)
      end

      redirect_to articles_path, notice: t("feeds.create.success")
    else
      redirect_to new_feed_path, alert: t("feeds.create.error")
    end
  rescue ActionController::ParameterMissing
    redirect_to new_feed_path, alert: t("feeds.create.url_required")
  end

  def show
    @feed = Current.user.feeds.find(params[:id])
    @articles = @feed.articles.recent
  rescue ActiveRecord::RecordNotFound
    redirect_to feeds_path, alert: t("feeds.show.not_found")
  end

  def destroy
    @feed = Current.user.feeds.find(params[:id])
    @feed.destroy

    redirect_to feeds_path, notice: t("feeds.destroy.success")
  rescue ActiveRecord::RecordNotFound
    redirect_to feeds_path, alert: t("feeds.show.not_found")
  end

  private

  def feed_params
    params.require(:feed).permit(:feed_url)
  end
end

Feed.where(favicon: nil).count
