module SupportInterface
  class EmailForm
    include ActiveModel::Model

    validates :email, presence: true, valid_for_notify: { if: :email }

    attr_accessor :email

    def save
      valid?
    end
  end
end
