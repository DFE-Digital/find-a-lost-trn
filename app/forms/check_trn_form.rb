# frozen_string_literal: true
class CheckTrnForm
  include ActiveModel::Model

  attr_accessor :has_trn

  validates :has_trn, inclusion: { in: %w[true false] }

  def trn?
    ActiveModel::Type::Boolean.new.cast(has_trn)
  end

  def email?
    false
  end
end
