# frozen_string_literal: true
class NoMatchForm
  include ActiveModel::Model

  attr_accessor :try_again

  validates :try_again, inclusion: { in: %w[true false] }

  def try_again?
    ActiveModel::Type::Boolean.new.cast(try_again)
  end
end
