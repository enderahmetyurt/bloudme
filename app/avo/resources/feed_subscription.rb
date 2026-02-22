class Avo::Resources::FeedSubscription < Avo::BaseResource
  def fields
    field :id, as: :id
    field :user, as: :belongs_to
    field :feed, as: :belongs_to
    field :created_at, as: :date_time
  end
end
