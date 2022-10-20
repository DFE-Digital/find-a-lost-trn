# frozen_string_literal: true
class TrnDetailsComponent < ViewComponent::Base
  def initialize(trn_request:, actions: false, anonymise: false)
    super
    @actions = actions
    @anonymise = anonymise
    @trn_request = trn_request

    if @actions && @anonymise
      raise ArgumentError, "Cannot render both actions and anonymised data"
    end
  end

  def official_name
    if @anonymise
      @trn_request
        .official_name
        .split
        .map { |name| "#{name.first}****" }
        .join(" ")
    else
      @trn_request.official_name
    end
  end

  def preferred_name
    if @anonymise
      @trn_request
        .preferred_name
        .split
        .map { |name| "#{name.first}****" }
        .join(" ")
    else
      @trn_request.preferred_name
    end
  end

  def date_of_birth
    if @anonymise
      "** ** ****"
    elsif @trn_request.date_of_birth?
      @trn_request.date_of_birth.to_fs(:long_ordinal_uk)
    else
      "Not given"
    end
  end

  def ni_key
    if @trn_request.has_ni_number?
      "National Insurance number"
    else
      "Do you have a National Insurance number?"
    end
  end

  def ni_value
    if @trn_request.has_ni_number? && !@trn_request.ni_number
      return "Not provided"
    end
    return "No" unless @trn_request.has_ni_number?

    if @anonymise
      "#{@trn_request.ni_number.first}* ** ** ** #{@trn_request.ni_number.last}"
    else
      helpers.pretty_ni_number(@trn_request.ni_number)
    end
  end

  def awarded_qts_value
    return "Yes" if @trn_request.awarded_qts?

    "No"
  end

  def itt_provider_key
    return "Where did you get your QTS?" if @trn_request.itt_provider_enrolled

    "Did a university, SCITT or school award your QTS?"
  end

  def itt_provider_value
    if @trn_request.itt_provider_enrolled
      @trn_request.itt_provider_name
    else
      "No, I was awarded QTS another way"
    end
  end

  def email
    return "Not provided" if @trn_request.email.nil?

    if @anonymise
      "#{@trn_request.email.first}****@****.#{@trn_request.email.split(".").last}"
    else
      helpers.shy_email(@trn_request.email)
    end
  end

  def previous_name
    if @anonymise
      @trn_request
        .previous_name
        .split
        .map { |name| "#{name.first}****" }
        .join(" ")
    else
      @trn_request.previous_name
    end
  end

  def trn_from_user_value
    return @trn_request.trn_from_user if @trn_request.trn_from_user.present?

    "I don’t know my TRN"
  end
end
