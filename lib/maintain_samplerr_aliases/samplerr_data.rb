require 'singleton'

module MaintainSamplerrAliases
  class SamplerrData
    include Singleton

    attr_reader :alias_prefix, :index_prefix

    def initialize
      @index_prefix = '.samplerr-'
      @alias_prefix = 'samplerr-'
    end

    def remove_existing_aliases
      aliases.each(&:destroy)
    end

    def remove_alias(a)
      client.schedule_remove_alias(a.alias, a.index)
    end

    def remove_index(i)
      client.remove_index(i.name)
    end

    def aliases
      client.aliases.select { |a| a['alias'].start_with?(alias_prefix) }.map do |a|
        Alias.new(a)
      end.sort_by(&:start_date)
    end

    def indices
      client.indices.select { |i| i['index'].start_with?(index_prefix) }.map do |i|
        Index.new(i)
      end.sort_by(&:start_date)
    end

    def daily_indices
      indices.select(&:daily?)
    end

    def monthly_indices
      indices.select(&:monthly?)
    end

    def yearly_indices
      indices.select(&:yearly?)
    end

    def daily_indices_start_date
      daily_indices.map(&:start_date).min
    end

    def monthly_indices_start_date
      monthly_indices.map(&:start_date).min
    end

    def yearly_indices_start_date
      yearly_indices.map(&:start_date).min
    end

    def add_daily_aliases
      add_aliases(daily_indices_start_date, today, :next_day, '%Y.%m.%d')
    end

    def add_monthly_aliases
      add_aliases(monthly_indices_start_date, daily_indices_start_date, :next_month, '%Y.%m')
    end

    def add_yearly_aliases
      add_aliases(yearly_indices_start_date, monthly_indices_start_date, :next_year, '%Y')
    end

    def today
      now = DateTime.now.new_offset(0)
      DateTime.new(now.year, now.month, now.day)
    end

    def commit
      client.commit
    end

    private

    def client
      @client ||= ElasticSearchAdapter.new
    end

    def add_aliases(from_date, to_date, stride, format)
      current_date = from_date

      while current_date.send(stride) <= to_date
        name = current_date.strftime(format)
        client.schedule_add_alias_if_index_exist(alias_prefix + name, index_prefix + name)
        current_date = current_date.send(stride)
      end

      return unless current_date <= to_date

      name = current_date.strftime(format)
      client.schedule_add_alias(alias_prefix + name, index_prefix + name, current_date < to_date ? to_date : nil)
    end
  end
end
