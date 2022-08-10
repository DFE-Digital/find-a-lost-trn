module SupportInterface
  class StaffController < SupportInterfaceController
    def index
      @staff = Staff.all
    end
  end
end
