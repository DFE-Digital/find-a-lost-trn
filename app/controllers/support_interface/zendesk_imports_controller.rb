module SupportInterface
  class ZendeskImportsController < SupportInterfaceController
    def new
      @form = ZendeskDeleteRequestImportForm.new
    end

    def create
      @form = ZendeskDeleteRequestImportForm.new(import_params)
      if @form.save
        redirect_to support_interface_zendesk_path
      else
        render :new
      end
    end

    private

    def import_params
      params.require(
        :support_interface_zendesk_delete_request_import_form
      ).permit(:file)
    end
  end
end
