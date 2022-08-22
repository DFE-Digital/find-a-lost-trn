module SupportInterface
  class ZendeskController < SupportInterfaceController
    def index
      @zendesk_tickets =
        Rails
          .cache
          .fetch("zendesk_tickets", expires_in: 1.hour) do
            ZendeskService.find_closed_tickets_from_6_months_ago.map do |t|
              ZendeskDeleteRequest.new.from(t)
            end
          end
    end

    def confirm_deletion
      @ticket_count = ZendeskService.find_closed_tickets_from_6_months_ago.count
      @delete_form = ZendeskTicketDeletionForm.new
    end

    def destroy
      @ticket_count = ZendeskService.find_closed_tickets_from_6_months_ago.count
      @delete_form =
        ZendeskTicketDeletionForm.new(
          actual_number_of_tickets: @ticket_count.to_s,
          number_of_tickets: destroy_params
        )

      if @delete_form.valid?
        flash[:success] = "Successfully deleted #{@ticket_count} tickets"
        redirect_to support_interface_zendesk_path
      else
        render :confirm_deletion
      end
    end

    private

    def destroy_params
      params
        .require(:support_interface_zendesk_ticket_deletion_form)
        .fetch(:number_of_tickets)
        .strip
    end
  end
end
