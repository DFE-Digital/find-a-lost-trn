module SupportInterface
  class ZendeskController < SupportInterfaceController
    include Pagy::Backend

    def index
      @zendesk_tickets =
        ZendeskService.find_closed_tickets_from_6_months_ago.map do |t|
          ZendeskDeleteRequest.new.from(t)
        end

      @pagy, @zendesk_delete_requests =
        pagy(ZendeskDeleteRequest.order(closed_at: :desc))
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
        DeleteOldZendeskTicketsJob.perform_later
        flash[:success] = "Scheduled #{@ticket_count} tickets for deletion"
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
