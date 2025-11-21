class AddTrialEndDateToUsers < ActiveRecord::Migration[8.2]
  def change
    add_column :users, :trial_end_date, :datetime
  end
end
