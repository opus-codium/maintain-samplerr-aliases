require 'maintain_samplerr_aliases'

RSpec.describe MaintainSamplerrAliases::SamplerrData do
  let(:pending_actions) { subject.instance_variable_get(:@actions) }

  context '#add_alias' do
    context 'without limit' do
      before do
        subject.add_alias('2020.04')
      end

      it 'adds actions to perform' do
        expect(pending_actions).to be_an(Array)
        expect(pending_actions).to_not be_empty
        expect(pending_actions.size).to be 1
        expect(pending_actions[0]).to eq(add: { index: '.samplerr-2020.04', alias: 'samplerr-2020.04' })
      end
    end

    context 'with limit' do
      before do
        subject.add_alias('2020.04', DateTime.new(2020, 4, 9, 0, 0, 0))
      end

      it 'adds actions to perform' do
        expect(pending_actions).to be_an(Array)
        expect(pending_actions).to_not be_empty
        expect(pending_actions.size).to be 1
        expect(pending_actions[0]).to eq(add: { index: '.samplerr-2020.04', alias: 'samplerr-2020.04', filter: { range: { '@timestamp': { lt: '2020-04-09T00:00:00Z' } } } })
      end
    end
  end

  context '#index_exist?' do
    before do
      expect(subject).to receive(:indices).and_return(indices)
    end

    let(:name) { '2020.03' }

    context 'with no indices' do
      let(:indices) { [] }

      it 'should return false' do
        expect(subject.index_exist?(name)).to be_falsey
      end
    end

    context 'with indices' do
      let(:indices) do
        [
          {
            'health' => 'green',
            'status' => 'open',
            'index' => '.samplerr-2020.04.10',
            'uuid' => 'C6L35CUtSyySiEKSTCtKjg',
            'pri' => '1',
            'rep' => '0',
            'docs.count' => '11279489',
            'docs.deleted' => '0',
            'store.size' => '1.3gb',
            'pri.store.size' => '1.3gb',
          },
          {
            'health' => 'green',
            'status' => 'open',
            'index' => '.samplerr-2020.03',
            'uuid' => 'faclwxvER_eIuwUJc1ryFQ',
            'pri' => '1',
            'rep' => '0',
            'docs.count' => '27002927',
            'docs.deleted' => '0',
            'store.size' => '3.5gb',
            'pri.store.size' => '3.5gb',
          },
          {
            'health' => 'green',
            'status' => 'open',
            'index' => '.samplerr-2020.04',
            'uuid' => 'pDpL7pa4Q4G8Rffmi9DNXw',
            'pri' => '1',
            'rep' => '0',
            'docs.count' => '9932442',
            'docs.deleted' => '0',
            'store.size' => '1.4gb',
            'pri.store.size' => '1.4gb',
          },
        ]
      end

      it 'should return false' do
        expect(subject.index_exist?(name)).to be_truthy
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
          { 'alias' => 'samplerr-2020.04.10', 'index' => '.samplerr-2020.04.10', 'filter' => '-', 'routing.index' => '-', 'routing.search' => '-' },
          { 'alias' => 'samplerr-2020.03',    'index' => '.samplerr-2020.03',    'filter' => '-', 'routing.index' => '-', 'routing.search' => '-' },
          { 'alias' => 'samplerr-2020.04.09', 'index' => '.samplerr-2020.04.09', 'filter' => '-', 'routing.index' => '-', 'routing.search' => '-' },
          { 'alias' => 'samplerr-2020',       'index' => '.samplerr-2020',       'filter' => '*', 'routing.index' => '-', 'routing.search' => '-' },
          { 'alias' => 'samplerr-2020.04.11', 'index' => '.samplerr-2020.04.11', 'filter' => '-', 'routing.index' => '-', 'routing.search' => '-' },
          { 'alias' => 'samplerr-2019',       'index' => '.samplerr-2019',       'filter' => '-', 'routing.index' => '-', 'routing.search' => '-' },
          { 'alias' => 'samplerr-2020.04',    'index' => '.samplerr-2020.04',    'filter' => '*', 'routing.index' => '-', 'routing.search' => '-' },
        ]
      end

      it 'adds actions to perform' do
        expect(pending_actions).to be_an(Array)
        expect(pending_actions).to_not be_empty
        expect(pending_actions.size).to be 7
        expect(pending_actions[0]).to eq(remove: { alias: 'samplerr-2020.04.10', index: '.samplerr-2020.04.10' })
      end
    end
  end
end
