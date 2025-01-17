namespace :update_feeds do
  desc "Run the UpdateFeedsJob"
  task run: :environment do
    UpdateFeedsJob.perform_later
  end
end
