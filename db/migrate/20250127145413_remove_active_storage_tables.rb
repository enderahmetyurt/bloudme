class RemoveActiveStorageTables < ActiveRecord::Migration[8.1]
  def up
    drop_table :active_storage_blobs
    drop_table :active_storage_attachments
    drop_table :active_storage_variant_records
  end
end
