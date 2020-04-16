require 'date'

module MaintainSamplerrAliases
  class SamplerrDataManager
    def initialize(days_retention, months_retention, years_retention)
      @days_retention = days_retention
      @months_retention = months_retention
      @years_retention = years_retention
    end

    def remove_expired_indices
      expired_indices.each(&:destroy)
    end

    def update_aliases
      client.remove_existing_aliases

      client.add_yearly_aliases
      client.add_monthly_aliases
      client.add_daily_aliases

      client.commit
    end

    private

    def client
      @client ||= SamplerrData.instance
    end

    def expired_indices
      expired_yearly_indices +
        expired_monthly_indices +
        expired_daily_indices
    end

    def expired_daily_indices
      client.daily_indices.select { |i| i.start_date < daily_data_start }
    end

    def expired_monthly_indices
      client.monthly_indices.select { |i| i.start_date < monthly_data_start }
    end

    def expired_yearly_indices
      client.yearly_indices.select { |i| i.start_date < yearly_data_start }
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
  end
end
