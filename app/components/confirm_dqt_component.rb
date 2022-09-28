# frozen_string_literal: true
class ConfirmDqtComponent < ViewComponent::Base
  def initialize(user:, dqt_record:)
    super
    @user = user
    @dqt_record = dqt_record
  end

  def teacher_full_name
    "#{@user.first_name} #{@user.last_name}"
  end

  def teacher_email
    helpers.shy_email(@user.email)
  end
end
