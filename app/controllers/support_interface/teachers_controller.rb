module SupportInterface
  class TeachersController < SupportInterfaceController
    def show
      @teacher = IdentityApi.get_teacher(uuid)
      @teacher_name =
        "#{@teacher.fetch(:firstName)} #{@teacher.fetch(:lastName)}"
    end

    private

    def uuid
      params.require(:uuid)
    end
  end
end
