class Avo::Resources::Article < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: params[:q], m: "or").result(distinct: false) }
  # }
  
  def fields
    field :id, as: :id
    field :content, as: :textarea
    field :feed_id, as: :number
    field :link, as: :text
    field :published_at, as: :date_time
    field :title, as: :text
    field :is_read, as: :boolean
    field :thumbnail, as: :text
    field :youtube_channel_id, as: :text
    field :youtube_video_id, as: :text
    field :feed, as: :belongs_to
  end
end


