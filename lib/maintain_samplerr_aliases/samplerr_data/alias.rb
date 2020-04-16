module MaintainSamplerrAliases
  class SamplerrData
    class Alias < Data
      def initialize(json)
        super(json, SamplerrData.instance.alias_prefix)
      end

      def name
        @data['alias']
      end

      def alias
        @data['alias']
      end

      def index
        @data['index']
      end

      def destroy
        SamplerrData.instance.remove_alias(self)
      end
    end
  end
end
