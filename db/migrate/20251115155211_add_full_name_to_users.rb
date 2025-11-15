class AddFullNameToUsers < ActiveRecord::Migration[8.2]
  def change
    add_column :users, :full_name, :string
  end
end
