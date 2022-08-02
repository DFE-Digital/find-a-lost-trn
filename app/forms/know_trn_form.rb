# frozen_string_literal: true
class KnowTrnForm
  include ActiveModel::Model
  include LogErrors

  attr_accessor :trn_request, :know_trn, :trn

  validates :know_trn, inclusion: { in: %w[true false] }

  def know_trn?
    ActiveModel::Type::Boolean.new.cast(know_trn)
  end

  def save
    if invalid?
      log_errors
      return false
    end

    trn_request.trn = trn
    trn_request.save!
  end
end
