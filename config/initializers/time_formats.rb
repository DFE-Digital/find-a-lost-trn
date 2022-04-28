# frozen_string_literal: true
Time::DATE_FORMATS[:long_ordinal_uk] = lambda { |time| time.strftime('%d %B %Y at %l:%M%P') }
