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
  end
end
