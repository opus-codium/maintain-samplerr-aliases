require 'date'

module MaintainSamplerrAliases
  class SamplerrData
    class Index < Data
      attr_reader :year, :month, :day

      def initialize(json)
        super(json, SamplerrData.instance.index_prefix)
      end

      def name
        @data['index']
      end

      def destroy
        SamplerrData.instance.remove_index(self)
      end
    end
  end
end
