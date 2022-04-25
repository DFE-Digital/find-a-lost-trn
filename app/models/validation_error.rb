# frozen_string_literal: true
class ValidationError < ApplicationRecord
  belongs_to :trn_request

  validates :form_object, presence: true
  validates :messages, presence: true
end
