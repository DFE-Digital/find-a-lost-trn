# frozen_string_literal: true
module DfE
  module Analytics
    # The gem copies the query string and referer into BigQuery as they are.
    # This passes both through Rails' parameter filters, so a token in a
    # password reset link doesn't leave the service
    class FilteredRequestEvent < Event
      def with_request_details(rack_request)
        super

        filter = rack_request.parameter_filter
        @event_hash.merge!(
          request_query: hash_to_kv_pairs(filter_query(rack_request.query_string, filter)),
          request_referer: filter_referer(rack_request.referer, filter),
        )

        self
      end

      private

      def filter_query(query_string, filter)
        filter.filter(Rack::Utils.parse_query(query_string))
      end

      def filter_referer(referer, filter)
        return if referer.blank?

        uri = URI.parse(referer)
        uri.query = Rack::Utils.build_query(filter_query(uri.query, filter)) if uri.query.present?

        ensure_utf8(uri.to_s)
      # Rack raises ArgumentError for invalid %-encoding in the query. A referer
      # we can't parse can't be filtered, so it doesn't go out
      rescue URI::InvalidURIError, ArgumentError
        nil
      end
    end
  end
end
