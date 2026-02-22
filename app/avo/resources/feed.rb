class Avo::Resources::Feed < Avo::BaseResource
  # self.includes = []
  # self.search = {
  #   query: -> { query.ransack(title_cont: params[:q]).result(distinct: false) }
  # }

  def fields
    field :id, as: :id
    field :title, as: :text
    field :feed_url, as: :text
    field :site_url, as: :text
    field :description, as: :textarea
    field :favicon, as: :text
    field :is_podcast, as: :boolean
    field :feed_subscriptions, as: :has_many
    field :articles, as: :has_many
  end

  def actions
    action Avo::Actions::ExportCsv
  end
end
