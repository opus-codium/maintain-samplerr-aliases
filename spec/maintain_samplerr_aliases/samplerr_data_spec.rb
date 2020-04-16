require 'maintain_samplerr_aliases'

RSpec.describe MaintainSamplerrAliases::SamplerrData do
  subject { described_class.instance }

  let(:client) { subject.send(:client) }
  let(:pending_actions) { client.instance_variable_get(:@actions) }

  after do
    client.rollback
  end

  context 'with raw aliases' do
    before do
      expect(client).to receive(:aliases).and_return(
        [
          { 'alias' => 'random',              'index' => '.random',              'filter' => '-', 'routing.index' => '-', 'routing.search' => '-' },
          { 'alias' => 'samplerr-2019',       'index' => '.samplerr-2019',       'filter' => '-', 'routing.index' => '-', 'routing.search' => '-' },
          { 'alias' => 'samplerr-2020',       'index' => '.samplerr-2020',       'filter' => '*', 'routing.index' => '-', 'routing.search' => '-' },
          { 'alias' => 'samplerr-2020.03',    'index' => '.samplerr-2020.03',    'filter' => '-', 'routing.index' => '-', 'routing.search' => '-' },
          { 'alias' => 'samplerr-2020.04',    'index' => '.samplerr-2020.04',    'filter' => '*', 'routing.index' => '-', 'routing.search' => '-' },
          { 'alias' => 'samplerr-2020.04.09', 'index' => '.samplerr-2020.04.09', 'filter' => '-', 'routing.index' => '-', 'routing.search' => '-' },
          { 'alias' => 'samplerr-2020.04.10', 'index' => '.samplerr-2020.04.10', 'filter' => '-', 'routing.index' => '-', 'routing.search' => '-' },
          { 'alias' => 'samplerr-2020.04.11', 'index' => '.samplerr-2020.04.11', 'filter' => '-', 'routing.index' => '-', 'routing.search' => '-' },
        ]
      )
    end

    context '#aliases' do
      it 'should return an array' do
        expect(subject.aliases).to be_an(Array)
      end

      it 'should only keep relevant items' do
        expect(subject.aliases.size).to eq(7)
      end
    end
  end

  context 'with raw indices' do
    before do
      expect(client).to receive(:indices).and_return(
        [
          { 'index' => '.random' },
          { 'index' => '.samplerr-2019' },
          { 'index' => '.samplerr-2020' },
          { 'index' => '.samplerr-2020.03' },
          { 'index' => '.samplerr-2020.04' },
          { 'index' => '.samplerr-2020.04.09' },
          { 'index' => '.samplerr-2020.04.10' },
          { 'index' => '.samplerr-2020.04.11' },
        ]
      )
    end

    context '#indices' do
      it 'should only keep relevant items' do
        expect(subject.indices.size).to eq(7)
      end
    end

    context '#yearly_indices_start_date' do
      it 'returns the right date' do
        expect(subject.yearly_indices_start_date).to eq(DateTime.new(2019, 1, 1))
      end
      it 'returns the right date' do
        expect(subject.monthly_indices_start_date).to eq(DateTime.new(2020, 3, 1))
      end
      it 'returns the right date' do
        expect(subject.daily_indices_start_date).to eq(DateTime.new(2020, 4, 9))
      end
    end
  end

  context '#add_aliases' do
    before do
      allow(client).to receive(:index_exist?).and_return(true)
      subject.send(:add_aliases, from_date, to_date, stride, format)
    end

    context 'yearly aliases' do
      let(:from_date) { DateTime.new(2011, 1, 1) }
      let(:to_date) { DateTime.new(2020, 3, 1) }
      let(:stride) { :next_year }
      let(:format) { '%Y' }

      it 'builds proper aliases' do
        expect(pending_actions).to eq(
          [
            { add: { alias: 'samplerr-2011', index: '.samplerr-2011' } },
            { add: { alias: 'samplerr-2012', index: '.samplerr-2012' } },
            { add: { alias: 'samplerr-2013', index: '.samplerr-2013' } },
            { add: { alias: 'samplerr-2014', index: '.samplerr-2014' } },
            { add: { alias: 'samplerr-2015', index: '.samplerr-2015' } },
            { add: { alias: 'samplerr-2016', index: '.samplerr-2016' } },
            { add: { alias: 'samplerr-2017', index: '.samplerr-2017' } },
            { add: { alias: 'samplerr-2018', index: '.samplerr-2018' } },
            { add: { alias: 'samplerr-2019', index: '.samplerr-2019' } },
            { add: { alias: 'samplerr-2020', index: '.samplerr-2020', filter: { range: { '@timestamp': { lt: '2020-03-01T00:00:00Z' } } } } },
          ]
        )
      end
    end

    context 'monthly aliases' do
      let(:from_date) { DateTime.new(2020, 3, 1) }
      let(:to_date) { DateTime.new(2020, 4, 9) }
      let(:stride) { :next_month }
      let(:format) { '%Y.%m' }

      it 'builds proper aliases' do
        expect(pending_actions).to eq(
          [
            { add: { alias: 'samplerr-2020.03', index: '.samplerr-2020.03' } },
            { add: { alias: 'samplerr-2020.04', index: '.samplerr-2020.04', filter: { range: { '@timestamp': { lt: '2020-04-09T00:00:00Z' } } } } },
          ]
        )
      end
    end

    context 'daily aliases' do
      let(:from_date) { DateTime.new(2020, 4, 9) }
      let(:to_date) { DateTime.new(2020, 4, 11) }
      let(:stride) { :next_day }
      let(:format) { '%Y.%m.%d' }

      it 'builds proper aliases' do
        expect(pending_actions).to eq(
          [
            { add: { alias: 'samplerr-2020.04.09', index: '.samplerr-2020.04.09' } },
            { add: { alias: 'samplerr-2020.04.10', index: '.samplerr-2020.04.10' } },
            { add: { alias: 'samplerr-2020.04.11', index: '.samplerr-2020.04.11' } },
          ]
        )
      end
    end
  end

  context '#remove_existing_aliases' do
    before do
      expect(subject).to receive(:aliases).and_return(aliases)
      subject.remove_existing_aliases
    end

    context 'with no aliases' do
      let(:aliases) { [] }

      it 'does not add actions to perform' do
        expect(pending_actions).to be_an(Array)
        expect(pending_actions).to be_empty
      end
    end

    context 'with aliases' do
      let(:aliases) do
        [
          MaintainSamplerrAliases::SamplerrData::Alias.new('alias' => 'samplerr-2019',       'index' => '.samplerr-2019',       'filter' => '-', 'routing.index' => '-', 'routing.search' => '-'),
          MaintainSamplerrAliases::SamplerrData::Alias.new('alias' => 'samplerr-2020',       'index' => '.samplerr-2020',       'filter' => '*', 'routing.index' => '-', 'routing.search' => '-'),
          MaintainSamplerrAliases::SamplerrData::Alias.new('alias' => 'samplerr-2020.03',    'index' => '.samplerr-2020.03',    'filter' => '-', 'routing.index' => '-', 'routing.search' => '-'),
          MaintainSamplerrAliases::SamplerrData::Alias.new('alias' => 'samplerr-2020.04',    'index' => '.samplerr-2020.04',    'filter' => '*', 'routing.index' => '-', 'routing.search' => '-'),
          MaintainSamplerrAliases::SamplerrData::Alias.new('alias' => 'samplerr-2020.04.09', 'index' => '.samplerr-2020.04.09', 'filter' => '-', 'routing.index' => '-', 'routing.search' => '-'),
          MaintainSamplerrAliases::SamplerrData::Alias.new('alias' => 'samplerr-2020.04.10', 'index' => '.samplerr-2020.04.10', 'filter' => '-', 'routing.index' => '-', 'routing.search' => '-'),
          MaintainSamplerrAliases::SamplerrData::Alias.new('alias' => 'samplerr-2020.04.11', 'index' => '.samplerr-2020.04.11', 'filter' => '-', 'routing.index' => '-', 'routing.search' => '-'),
        ]
      end

      it 'adds actions to perform' do
        expect(pending_actions).to be_an(Array)
        expect(pending_actions).to_not be_empty
        expect(pending_actions.size).to be 7
        expect(pending_actions[5]).to eq(remove: { alias: 'samplerr-2020.04.10', index: '.samplerr-2020.04.10' })
      end
    end
  end
end
