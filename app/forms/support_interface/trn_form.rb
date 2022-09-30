module SupportInterface
  class TrnForm
    include ActiveModel::Model

    validates :trn, presence: true, length: { is: 7 }

    attr_accessor :trn

    def save
      valid?
    end
  end
end
