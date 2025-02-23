class Avo::Resources::User < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: params[:q], m: "or").result(distinct: false) }
  # }
  
  def fields
    field :id, as: :id
    field :avatar_url, as: :text
    field :email_address, as: :text
    field :nick_name, as: :text
    field :is_admin, as: :boolean
    field :sessions, as: :has_many
    field :posts, as: :has_many
    field :feeds, as: :has_many
  end
end


