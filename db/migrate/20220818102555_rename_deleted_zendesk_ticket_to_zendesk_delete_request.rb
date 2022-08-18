class RenameDeletedZendeskTicketToZendeskDeleteRequest < ActiveRecord::Migration[
  7.0
]
  def change
    rename_table :deleted_zendesk_tickets, :zendesk_delete_requests
  end
end
