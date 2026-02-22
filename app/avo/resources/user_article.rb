class Avo::Resources::UserArticle < Avo::BaseResource
  def fields
    field :id, as: :id
    field :user, as: :belongs_to
    field :article, as: :belongs_to
    field :is_read, as: :boolean
    field :created_at, as: :date_time
  end
end
