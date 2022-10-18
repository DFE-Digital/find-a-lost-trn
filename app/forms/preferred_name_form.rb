# frozen_string_literal: true
class PreferredNameForm
  include ActiveModel::Model
  include LogErrors

  attr_accessor(
    :trn_request,
    :official_name_is_preferred,
    :preferred_first_name,
    :preferred_last_name,
  )

  delegate(
    :official_name,
    to: :trn_request,
  )

  def save!
    trn_request.preferred_first_name = preferred_first_name
    trn_request.preferred_last_name = preferred_last_name
    trn_request.save!
  end
end

