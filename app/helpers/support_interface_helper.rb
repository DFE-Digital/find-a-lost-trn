# frozen_string_literal: true

module SupportInterfaceHelper
  def user_info_link(user)
    govuk_link_to(
      user.full_name,
      support_interface_identity_user_path(user.uuid),
    )
  end

  def user_dqt_record_status(user)
    if user.trn
      tag.span("Yes")
    else
      link =
        govuk_link_to(
          "(Add a DQT record)",
          edit_support_interface_identity_user_path(user.uuid),
        )
      "#{tag.span("No")} #{link}".html_safe
    end
  end

  def dqt_record_text(user)
    user.trn ? "Yes" : "No record linked"
  end

  def dqt_record_link_text(user)
    user.trn ? "Change record" : "Add record"
  end
end
