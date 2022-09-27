# frozen_string_literal: true
module SupportInterface
  class ConfirmDqtRecordForm
    include ActiveModel::Model
    include LogErrors

    attr_accessor :add_dqt_record, :trn

    validates :add_dqt_record, inclusion: { in: %w[Yes No] }

    def confirmed?
      add_dqt_record.downcase == "yes"
    end
  end
end
