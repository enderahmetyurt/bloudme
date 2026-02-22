class Avo::Resources::User < Avo::BaseResource
  # self.includes = []
  # self.search = {
  #   query: -> { query.ransack(email_address_cont: params[:q]).result(distinct: false) }
  # }

  def fields
    field :id, as: :id
    field :email_address, as: :text
    field :nick_name, as: :text
    field :full_name, as: :text
    field :avatar_url, as: :text
    field :is_admin, as: :boolean
    field :subscription_active, as: :boolean
    field :trial_end_date, as: :date_time
    field :sessions, as: :has_many
    field :feed_subscriptions, as: :has_many
    field :bookmarks, as: :has_many
  end

  def actions
    action Avo::Actions::ExportCsv
  end
end
