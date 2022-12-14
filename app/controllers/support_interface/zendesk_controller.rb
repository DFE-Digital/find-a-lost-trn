require "csv"

module SupportInterface
  class ZendeskController < SupportInterfaceController
    include Pagy::Backend

    def index
      closed_tickets = ZendeskService.find_closed_tickets_from_6_months_ago
      @zendesk_tickets =
        closed_tickets.map { |t| ZendeskDeleteRequest.new.from(t) }

      @zendesk_tickets_total = closed_tickets.count

      @zendesk_delete_requests_total = ZendeskDeleteRequest.count

      @pagy, @zendesk_delete_requests =
        pagy(ZendeskDeleteRequest.order(closed_at: :desc))

      @export_form = SupportInterface::ZendeskExportForm.new
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
          number_of_tickets: destroy_params,
        )

      if @delete_form.valid?
        ScheduleZendeskTicketsForDeletionJob.perform_later
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
