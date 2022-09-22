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
      @user = IdentityApi.get_teacher(uuid)
    end

    private

    def uuid
      params.require(:uuid)
    end
  end
end
