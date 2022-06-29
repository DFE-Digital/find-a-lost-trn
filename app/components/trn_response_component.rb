# frozen_string_literal: true
class TrnResponseComponent < ViewComponent::Base
  include ActiveModel::API

  attr_accessor :anonymise, :trn_response
  delegate :trn_request, to: :trn_response

  def awarded_qts?
    return false if trn_response.raw_result["qualified_teacher_status"].nil?

    (
      trn_response.raw_result["qualified_teacher_status"]["state"] == "Active"
    ) != trn_request.awarded_qts
  end

  def awarded_qts_value
    return nil if trn_response.raw_result.blank?
    return nil unless trn_response.raw_result.key?("qualified_teacher_status")
    return nil if trn_response.raw_result["qualified_teacher_status"].nil?
    if trn_response.raw_result["qualified_teacher_status"]["state"] == "Active"
      return "Yes"
    end

    "No"
  end

  def itt_provider?
    return false if trn_response.raw_result["initial_teacher_training"].nil?

    (
      trn_response.raw_result["initial_teacher_training"]["state"] == "Active"
    ) != trn_request.itt_provider_enrolled
  end

  def itt_provider_value
    return nil if trn_response.raw_result["initial_teacher_training"].nil?

    if trn_response.raw_result["initial_teacher_training"]["state"] == "Active"
      "Yes"
    else
      "No"
    end
  end

  def name
    return nil if trn_response.raw_result["name"].blank?

    if anonymise
      trn_response.raw_result["name"]
        .split
        .map { |name| "#{name.first}****" }
        .join(" ")
    else
      trn_response.raw_result["name"]
    end
  end

  def name?
    trn_response.raw_result["name"] != trn_request.name
  end

  def ni?
    trn_response.raw_result["ni_number"] != trn_request.ni_number
  end

  def ni_value
    return nil unless trn_response.raw_result["ni_number"]

    if @anonymise
      "#{trn_response.raw_result["ni_number"].first}* ** ** ** #{trn_response.raw_result["ni_number"].last}"
    else
      helpers.pretty_ni_number(trn_response.raw_result["ni_number"])
    end
  end
end
