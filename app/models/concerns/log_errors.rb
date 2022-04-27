# frozen_string_literal: true
module LogErrors
  extend ActiveSupport::Concern

  included do
    def log_errors
      return unless FeatureFlag.active?(:log_validation_errors)

      error_messages =
        errors.messages.to_h { |field, messages| [field, { messages: messages, value: public_send(field) }] }
      ValidationError.create(form_object: self.class.name, messages: error_messages, trn_request: trn_request)
    end
  end
end
