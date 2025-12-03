class AddCascadingForeignKeys < ActiveRecord::Migration[7.1]
  def change
    remove_foreign_key :sent_files, column: :sync_id
    add_foreign_key :sent_files,
                    :syncs,
                    column: :sync_id,
                    on_delete: :cascade

    remove_foreign_key :syncs, column: :sender_payload_id
    add_foreign_key :syncs,
                    :sender_payloads,
                    column: :sender_payload_id,
                    on_delete: :cascade
  end
end
