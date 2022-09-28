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
      @user = IdentityApi.get_user(uuid)
      @dqt_record =
        DqtApi.find_teacher!(
          date_of_birth: @user.date_of_birth,
          trn: @user.trn,
        ) if @user.trn
    end

    private

    def uuid
      params.require(:uuid)
    end

    def trn
      params.require(:trn)
    end
  end
end
