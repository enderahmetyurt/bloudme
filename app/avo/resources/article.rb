class Avo::Resources::Article < Avo::BaseResource
  # self.includes = []
  # self.search = {
  #   query: -> { query.ransack(title_cont: params[:q]).result(distinct: false) }
  # }

  def fields
    field :id, as: :id
    field :title, as: :text
    field :link, as: :text
    field :published_at, as: :date_time
    field :content, as: :textarea
    field :thumbnail, as: :text
    field :youtube_channel_id, as: :text
    field :youtube_video_id, as: :text
    field :feed, as: :belongs_to
    field :user_articles, as: :has_many
  end

  def actions
    action Avo::Actions::ExportCsv
  end
end
