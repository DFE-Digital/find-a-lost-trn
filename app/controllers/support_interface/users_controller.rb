# frozen_string_literal: true
module SupportInterface
  class UsersController < SupportInterfaceController
    include Pagy::Backend

    def index
      @all_users ||= IdentityApi.get_users
      @total = @all_users.size
      @pagy, @users = pagy_array(@all_users)
    end

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
