class ChangeColumnNullCustomFields < ActiveRecord::Migration[7.0]
  def change
    change_column_null :zendesk_delete_requests, :enquiry_type, true
    change_column_null :zendesk_delete_requests, :no_action_required, true
  end
end
