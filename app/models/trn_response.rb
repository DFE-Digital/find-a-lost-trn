# frozen_string_literal: true
class TrnResponse < ApplicationRecord
  belongs_to :trn_request

  def diff
    return nil if raw_result.blank?

    raw_result
      .slice('name', 'ni_number')
      .each_with_object({}) { |(key, value), result| result[key] = value unless value == trn_request.send(key) }
      .symbolize_keys
  end
end
