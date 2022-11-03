module SupportInterface
  class ChangeNameForm
    include ActiveModel::Model

    attr_accessor :first_name, :last_name

    validates :first_name, presence: true, length: { maximum: 255 }
    validates :last_name, presence: true, length: { maximum: 255 }

    def save
      valid?
    end
  end
end
