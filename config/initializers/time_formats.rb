# frozen_string_literal: true
Time::DATE_FORMATS[:long_ordinal_uk] = lambda do |time|
  time.strftime("%d %B %Y at %l:%M%P")
end
