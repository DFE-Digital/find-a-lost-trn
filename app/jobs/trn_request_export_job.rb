class TrnRequestExportJob < ApplicationJob
  queue_as :default

  def perform
    return unless FeatureFlag.active?(:automated_trn_exports)

    export_form =
      SupportInterface::TrnRequestExportForm.new(time_period: 1.month.ago)
    csv = TrnRequest.to_csv(export_form.scope)

    TrnExportMailer.monthly_report(csv).deliver_later
  end
end
