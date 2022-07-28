# frozen_string_literal: true

class UpdateNameChangedFieldForTrnRequests < ActiveRecord::Migration[7.0]
  def up
    ApplicationRecord.transaction do
      TrnRequest.find_each do |trn_request|
        # Set name changed to true if a previous name has already been entered
        trn_request.update!(name_changed: true) if trn_request.previous_first_name.present? ||
                                                   trn_request.previous_last_name.present?
      end
    end
  end

  def down
    # By default user has not specified whether name has been changed
    TrnRequest.update_all(name_changed: nil)
  end
end
