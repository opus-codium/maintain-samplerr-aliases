require 'date'

module MaintainSamplerrAliases
  class SamplerrDataManager
    def initialize(days_retention, months_retention, years_retention)
      @days_retention = days_retention
      @months_retention = months_retention
      @years_retention = years_retention
    end

    def daily_data_start
      date = today.prev_day(@days_retention - 1)
      DateTime.new(date.year, date.month, date.day)
    end

    def monthly_data_start
      date = today.prev_month(@months_retention - 1)
      DateTime.new(date.year, date.month, 1)
    end

    def yearly_data_start
      date = today.prev_year(@years_retention - 1)
      DateTime.new(date.year, 1, 1)
    end

    def today
      now = DateTime.now.new_offset(0)
      DateTime.new(now.year, now.month, now.day)
    end

    def update_aliases
      client = SamplerrData.new

      client.remove_existing_aliases

      client.add_aliases(yearly_data_start, monthly_data_start, :next_year, '%Y')
      client.add_aliases(monthly_data_start, daily_data_start, :next_month, '%Y.%m')
      client.add_aliases(daily_data_start, today, :next_day, '%Y.%m.%d')

      client.commit
    end
  end
end
