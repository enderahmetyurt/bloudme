class AddEmailConfirmationToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :email_confirmed, :boolean
    add_column :users, :confirmation_token, :string
    add_column :users, :confirmation_sent_at, :datetime
  end
end
