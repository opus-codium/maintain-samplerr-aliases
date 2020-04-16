module MaintainSamplerrAliases
  class SamplerrData
    class Data
      attr_reader :name
      attr_reader :year, :month, :day

      def initialize(json, prefix)
        @data = json

        match_data = name.match(/\A#{prefix}(?<year>\d+)(.(?<month>\d{2})(\.(?<day>\d{2}))?)?\z/)

        @year = Integer(match_data['year'], 10)
        @month = match_data['month'] && Integer(match_data['month'], 10)
        @day = match_data['day'] && Integer(match_data['day'], 10)
      end

      def yearly?
        month.nil?
      end

      def monthly?
        month && day.nil?
      end

      def daily?
        day
      end

      def start_date
        @start_date ||= DateTime.new(year, month || 1, day || 1)
      end

      def end_date
        @end_date ||= if yearly?
                        start_date.next_year
                      elsif monthly?
                        start_date.next_month
                      else
                        start_date.next_day
                      end
      end
    end
  end
end
