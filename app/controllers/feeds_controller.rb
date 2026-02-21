class FeedsController < ApplicationController
  def index
    redirect_to new_feed_path if Current.user.subscribed_feeds.empty?

    @feeds = Current.user.subscribed_feeds
  end

  def new
    @feed = Feed.new
  end

  def create
    feed_url = feed_params[:feed_url]
    if feed_url.blank?
      redirect_to new_feed_path, alert: t("feeds.create.url_required")
      return
    end

    parsed_feed = RssParserService.fetch_and_parse(feed_url)

    if parsed_feed
      @feed = Feed.find_or_initialize_by(feed_url: parsed_feed[:feed_url])
      @feed.assign_attributes(
        site_url: parsed_feed[:site_url],
        favicon: parsed_feed[:favicon] || "default-favicon.png",
        is_podcast: parsed_feed[:is_podcast],
        title: parsed_feed[:title],
        description: parsed_feed[:description],
        user: @feed.user || Current.user
      )
      @feed.save!

      FeedSubscription.find_or_create_by!(user: Current.user, feed: @feed)

      parsed_feed[:entries].each do |entry|
        article = @feed.articles.find_or_create_by!(link: entry[:link]) do |a|
          a.assign_attributes(entry.except(:link))
        end

        UserArticle.find_or_create_by!(user: Current.user, article: article)
      end

      redirect_to articles_path, notice: t("feeds.create.success")
    else
      redirect_to new_feed_path, alert: t("feeds.create.error")
    end
  rescue ActionController::ParameterMissing
    redirect_to new_feed_path, alert: t("feeds.create.url_required")
  end

  def show
    @feed = Current.user.subscribed_feeds.find(params[:id])
    @articles = @feed.articles.recent.includes(:bookmarks)
  rescue ActiveRecord::RecordNotFound
    redirect_to feeds_path, alert: t("feeds.show.not_found")
  end

  def destroy
    subscription = Current.user.feed_subscriptions.find_by!(feed_id: params[:id])
    subscription.destroy

    redirect_to feeds_path, notice: t("feeds.destroy.success")
  rescue ActiveRecord::RecordNotFound
    redirect_to feeds_path, alert: t("feeds.show.not_found")
  end

  private

  def feed_params
    params.require(:feed).permit(:feed_url)
  end
end
