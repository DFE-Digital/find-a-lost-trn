module SupportInterface
  class ZendeskCsvExportsController < SupportInterfaceController
    def create
      filename = "#{Time.zone.today}_deleted_zendesk_tickets.csv"
      respond_to do |format|
        format.csv { send_data ZendeskDeleteRequest.to_csv, filename: }
      end
    end
  end
end
