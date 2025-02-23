class Avo::Resources::Feed < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: params[:q], m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id
    field :description, as: :textarea
    field :title, as: :text
    field :url, as: :text
    field :user_id, as: :number
    field :user, as: :belongs_to
    field :articles, as: :has_many
  end
end
