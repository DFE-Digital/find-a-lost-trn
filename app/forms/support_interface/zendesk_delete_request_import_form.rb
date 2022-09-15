module SupportInterface
  class ZendeskDeleteRequestImportForm
    include ActiveModel::Model

    attr_accessor :file

    validates :file, presence: true

    def save
      return false unless valid?

      ZendeskDeleteRequest.from_csv(file)
    end
  end
end
