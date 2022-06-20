# frozen_string_literal: true
class FetchTrnFromZendesk
  TRN_REGEX = /\*\*(\d{7})\*\*/

  include ActiveModel::Model

  attr_accessor :trn_request

  validates :trn_request, presence: true

  delegate :date_of_birth, :zendesk_ticket_id, to: :trn_request

  def call
    return false unless valid?
    return false unless zendesk_ticket.comments.many?

    update_from_zendesk
  end

  private

  def trn
    @trn ||=
      zendesk_ticket.comments[1..]
        .find { |comment| comment.body.scan(TRN_REGEX).flatten.first }
        .body
        .scan(TRN_REGEX)
        .flatten
        .first
  end

  def update_from_zendesk
    return if trn.blank?

    raw_result = DqtApi.find_teacher!(date_of_birth: date_of_birth, trn: trn)
    trn_request.trn_responses.create(raw_result: raw_result)
    trn_request.update(trn: raw_result['trn'])
  end

  def zendesk_ticket
    @zendesk_ticket ||= ZendeskService.find_ticket(zendesk_ticket_id)
  end
end
