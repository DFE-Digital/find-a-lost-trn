# frozen_string_literal: true
class TrnDetailsComponent < ViewComponent::Base
  def initialize(trn_request:, actions: false, anonymise: false)
    @actions = actions
    @anonymise = anonymise
    @trn_request = trn_request

    raise ArgumentError, 'Cannot render both actions and anonymised data' if @actions && @anonymise
  end

  def name
    if @anonymise
      @trn_request.name
        .split(' ')
        .map {|name| name.first + '****' }
        .join(' ')
    else
      @trn_request.name
    end
  end

  def date_of_birth
    if @anonymise
      '** ** ****'
    else
      @trn_request.date_of_birth? ? @trn_request.date_of_birth.to_fs(:long_ordinal_uk) : 'Not given'
    end
  end

  def ni_key
    @trn_request.has_ni_number? ? 'National Insurance number' : 'Do you have a National Insurance number?'
  end

  def ni_value
    if @anonymise && @trn_request.has_ni_number?
      @trn_request.ni_number.first + '* ** ** ** ' + @trn_request.ni_number.last
    else
      @trn_request.has_ni_number? ? helpers.pretty_ni_number(@trn_request.ni_number) : 'No'
    end
  end

  def itt_provider_key
    @trn_request.itt_provider_enrolled ? 'Where did you get your QTS?' : 'Have you been awarded QTS?'
  end

  def itt_provider_value
    @trn_request.itt_provider_enrolled ? @trn_request.itt_provider_name : 'No'
  end

  def email
    if @anonymise && !@trn_request.email.nil?
      @trn_request.email.first + '****@****.' + @trn_request.email.split('.').last
    else
      @trn_request.email
    end
  end

  def previous_name
    if @anonymise
      @trn_request.previous_name
        .split(' ')
        .map {|name| name.first + '****' }
        .join(' ')
    else
      @trn_request.previous_name
    end
  end
end
