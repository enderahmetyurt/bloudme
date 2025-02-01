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
  end

  def update_read
    @article = Article.find(params[:id])
    @article.update(is_read: ActiveModel::Type::Boolean.new.cast(params[:article][:read]))

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove("#{helpers.dom_id(@article)}_container") }
      format.html { redirect_to articles_path, notice: "Updated todo status." }
    end
  end
end
