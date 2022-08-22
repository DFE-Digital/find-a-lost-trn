module SupportInterface
  class ConsoleController < SupportInterfaceController
    def show
      @console_session = RVT::ConsoleSession.create # rubocop:disable Rails/SaveBang
    end
  end
end
