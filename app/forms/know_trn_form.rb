# frozen_string_literal: true
class KnowTrnForm
  include ActiveModel::Model
  include LogErrors

  attr_accessor :know_trn

  validates :know_trn, inclusion: { in: %w[true false] }

  def know_trn?
    ActiveModel::Type::Boolean.new.cast(know_trn)
  end

  def trn_request
    TrnRequest.new
  end

  def valid?
    super.tap { |result| log_errors unless result }
  end
end
