module SupportInterface
  class TrnRequestCsvExportsController < SupportInterfaceController
    def create
      @export_form =
        SupportInterface::TrnRequestExportForm.new(
          trn_request_export_form_params,
        )

      respond_to do |format|
        format.csv do
          send_data TrnRequest.to_csv(@export_form.scope),
                    filename: @export_form.filename
        end
      end
    end

    private

    def trn_request_export_form_params
      params.require(:support_interface_trn_request_export_form).permit(
        :time_period,
      )
    end
  end
end
