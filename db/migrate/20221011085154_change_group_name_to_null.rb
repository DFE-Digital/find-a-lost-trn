class ChangeGroupNameToNull < ActiveRecord::Migration[7.0]
  def change
    change_column_null :zendesk_delete_requests, :group_name, true
  end
end
