module OkComputerChecks
  class ZendeskCheck < OkComputer::Check
    def check
      GDS_ZENDESK_CLIENT.ticket.count!
      mark_message "Zendesk is connected"
    rescue StandardError => e
      mark_failure
      mark_message e.message
    end
  end
end
