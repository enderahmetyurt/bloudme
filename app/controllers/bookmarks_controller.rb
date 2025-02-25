class BookmarksController < ApplicationController
  def index
    bookmarks = Current.user.bookmarks
    @articles = Article.where(id: bookmarks.pluck(:article_id))
  end
end
