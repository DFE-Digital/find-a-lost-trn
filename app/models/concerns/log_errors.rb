# frozen_string_literal: true
module LogErrors
  extend ActiveSupport::Concern

  included do
    def log_errors
      return unless FeatureFlag.active?(:log_validation_errors)

      ValidationError.create(form_object: self.class.name, messages: errors.messages, trn_request: trn_request)
    end
  end
end
