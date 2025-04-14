class CreateJobRuns < ActiveRecord::Migration[7.1]
  def change
    create_table :job_runs do |t|
      t.string :job_class
      t.references :user, null: false, foreign_key: true
      t.datetime :ran_at
      t.datetime :next_run_at

      t.timestamps
    end
  end
end
