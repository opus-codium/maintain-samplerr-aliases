require 'elasticsearch'

module MaintainSamplerrAliases
  class ElasticSearchAdapter
    def initialize
      @actions = []
    end

    def remove_index(index_name)
      client.indices.remove(index_name)
      @indices = nil
    end

    def schedule_remove_alias(alias_name, index_name)
      @actions << {
        remove: {
          alias: alias_name,
          index: index_name,
        },
      }
    end

    def schedule_add_alias_if_index_exist(alias_name, index_name, limit = nil)
      return unless index_exist?(index_name)

      schedule_add_alias(alias_name, index_name, limit)
    end

    def schedule_add_alias(alias_name, index_name, limit = nil)
      action = { index: index_name, alias: alias_name }
      action[:filter] = { range: { '@timestamp': { lt: limit.strftime('%Y-%m-%dT%H:%M:%SZ') } } } if limit
      @actions << { add: action }
    end

    def commit
      client.indices.update_aliases body: {
        actions: @actions,
      }
      @actions = []
    end

    def rollback
      @actions = []
    end

    def aliases
      @aliases ||= client.cat.aliases(format: 'json')
    end

    def indices
      @indices ||= client.cat.indices(format: 'json')
    end

    private

    def client
      @client ||= Elasticsearch::Client.new(log: false)
    end

    def index_exist?(index_name)
      indices.select { |i| i['index'] == index_name }.any?
    end
  end
end
