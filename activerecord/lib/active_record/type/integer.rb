module ActiveRecord
  module Type
    class Integer < Value # :nodoc:
      include Numeric

      # Column storage size in bytes.
      # 4 bytes means a MySQL int or Postgres integer as opposed to smallint etc.
      DEFAULT_LIMIT = 4

      def initialize(*)
        super
        @range = min_value...max_value
      end

      def type
        :integer
      end

      def type_cast_from_database(value)
        return if value.nil?
        value.to_i
      end

      def type_cast_for_database(value)
        result = type_cast(value)
        if result
          ensure_in_range(result)
        end
        result
      end

      protected

      attr_reader :range

      private

      def cast_value(value)
        case value
        when true then 1
        when false then 0
        else
          value.to_i rescue nil
        end
      end

      def ensure_in_range(value)
        unless range.cover?(value)
          raise RangeError, "#{value} is out of range for #{self.class} with limit #{limit || DEFAULT_LIMIT}"
        end
      end

      def max_value
        limit = self.limit || DEFAULT_LIMIT
        1 << (limit * 8 - 1) # 8 bits per byte with one bit for sign
      end

      def min_value
        -max_value
      end
    end
  end
end
