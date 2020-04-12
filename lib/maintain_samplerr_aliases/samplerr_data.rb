require 'elasticsearch'

module MaintainSamplerrAliases
  class SamplerrData
    attr_reader :index_prefix, :alias_prefix

    def initialize
      @index_prefix = '.samplerr-'
      @alias_prefix = 'samplerr-'

      @actions = []
    end

    def remove_existing_aliases
      aliases.each do |a|
        @actions << {
          remove: {
            index: a['index'],
            alias: a['alias'],
          },
        }
      end
    end

    def add_aliases(from_date, to_date, stride, format)
      current_date = from_date

      while current_date.send(stride) <= to_date
        name = current_date.strftime(format)
        add_alias(name) if index_exist?(name)
        current_date = current_date.send(stride)
      end

      return unless current_date <= to_date

      name = current_date.strftime(format)
      add_alias(name, current_date < to_date ? to_date : nil)
    end

    def add_alias(name, limit = nil)
      action = { index: "#{index_prefix}#{name}", alias: "#{alias_prefix}#{name}" }
      action[:filter] = { range: { '@timestamp': { lt: limit.strftime('%Y-%m-%dT%H:%M:%SZ') } } } if limit
      @actions << { add: action }
    end

    def index_exist?(name)
      index = "#{index_prefix}#{name}"
      indices.select { |i| i['index'] == index }.any?
    end

    def commit
      client.indices.update_aliases body: {
        actions: @actions,
      }
      @actions = []
    end

    private

    def aliases
      @aliases ||= client.cat.aliases(format: 'json').select { |a| a['alias'].start_with?(alias_prefix) }
    end

    def indices
      @indices ||= client.cat.indices(format: 'json').select { |i| i['index'].start_with?(index_prefix) }
    end

    def client
      @client ||= Elasticsearch::Client.new(log: false)
    end
  end
end
