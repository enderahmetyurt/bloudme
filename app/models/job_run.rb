class JobRun < ApplicationRecord
  belongs_to :user

  validates :job_class, presence: true
  validates :ran_at, presence: true
end
