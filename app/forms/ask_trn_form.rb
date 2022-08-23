# frozen_string_literal: true
class AskTrnForm
  include ActiveModel::Model
  include LogErrors

  attr_accessor :do_you_know_your_trn, :trn_request

  validates :do_you_know_your_trn, inclusion: { in: %w[true false] }
  validates :trn_from_user,
            presence: true,
            length: {
              is: 7
            },
            if: -> { do_you_know_your_trn == "true" }

  delegate :trn_from_user, to: :trn_request, allow_nil: true

  def update(params = {})
    self.do_you_know_your_trn = params[:do_you_know_your_trn]
    self.trn_from_user =
      (trn_from_user_not_known? ? "" : params[:trn_from_user])

    if invalid?
      log_errors
      return false
    end

    trn_request.save!
  end

  def trn_from_user=(value)
    trn_request.trn_from_user = value&.delete("^0-9")
  end

  def trn_from_user_not_known?
    do_you_know_your_trn == "false"
  end

  def assign_form_values
    self.do_you_know_your_trn = "true" if trn_request.trn_from_user.present?
    self
  end
end
