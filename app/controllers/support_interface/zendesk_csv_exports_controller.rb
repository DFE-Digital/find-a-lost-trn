module SupportInterface
  class ZendeskCsvExportsController < SupportInterfaceController
    def create
      @export_form =
        SupportInterface::ZendeskExportForm.new(zendesk_export_form_params)

      respond_to do |format|
        format.csv do
          send_data ZendeskDeleteRequest.to_csv(@export_form.scope),
                    filename: @export_form.filename
        end
      end
    end

    private

    def zendesk_export_form_params
      params.require(:support_interface_zendesk_export_form).permit(
        :time_period,
      )
    end
  end
end
