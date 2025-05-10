require "csv"

module Maintenance
  class ImportUsersTask < MaintenanceTasks::Task
    csv_collection

    def process(row)
      collection.each do |row|
        User.create!(id: row["id"],
        email_address: row["email_address"],
        password_digest: row["password_digest"],
        created_at: row["created_at"],
        updated_at: row["updated_at"],
        avatar_url: row["avatar_url"],
        nick_name: row["nick_name"],
        is_admin: convert_to_boolean(row["is_admin"]),
        )
      end
    end

    def convert_to_boolean(value)
      if value == "TRUE"
        true
      else
        false
      end
    end
  end
end
