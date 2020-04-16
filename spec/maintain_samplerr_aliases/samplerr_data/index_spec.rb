require 'maintain_samplerr_aliases'
require 'maintain_samplerr_aliases/samplerr_data'
require 'maintain_samplerr_aliases/samplerr_data/index'

RSpec.describe MaintainSamplerrAliases::SamplerrData::Index do
  let(:index) do
    described_class.new(json)
  end

  shared_context 'daily index' do
    let(:json) do
      {
        'health' => 'green',
        'status' => 'open',
        'index' => '.samplerr-2020.04.13',
        'uuid' => 'gpBZQ9CbTzq7qLUPBqbuYQ',
        'pri' => '1',
        'rep' => '0',
        'docs.count' => '15755073',
        'docs.deleted' => '0',
        'store.size' => '2.1gb',
        'pri.store.size' => '2.1gb',
      }
    end
  end

  shared_context 'monthly index' do
    let(:json) do
      {
        'health' => 'green',
        'status' => 'open',
        'index' => '.samplerr-2020.04',
        'uuid' => 'jQuDDMPvQGGqpo0Oll3ttw',
        'pri' => '1',
        'rep' => '0',
        'docs.count' => '18371965',
        'docs.deleted' => '0',
        'store.size' => '2.4gb',
        'pri.store.size' => '2.4gb',
      }
    end
  end

  shared_context 'yearly index' do
    let(:json) do
      {
        'health' => 'green',
        'status' => 'open',
        'index' => '.samplerr-2020',
        'uuid' => 'w6OwLlU9QXSYUYEu4Y0Ofg',
        'pri' => '1',
        'rep' => '0',
        'docs.count' => '54465833',
        'docs.deleted' => '0',
        'store.size' => '6.9gb',
        'pri.store.size' => '6.9gb',
      }
    end
  end

  describe '#initialize' do
    include_context 'daily index'

    it 'detects a correct index date' do
      expect(index.year).to eq 2020
      expect(index.month).to eq 4
      expect(index.day).to eq 13
    end
  end

  describe '#yearly?' do
    subject { index.yearly? }

    context 'with a daily index' do
      include_context 'daily index'

      it { is_expected.to be_falsey }
    end

    context 'with a monthly index' do
      include_context 'monthly index'

      it { is_expected.to be_falsey }
    end

    context 'with a yearly index' do
      include_context 'yearly index'

      it { is_expected.to be_truthy }
    end
  end

  describe '#monthly?' do
    subject { index.monthly? }

    context 'with a daily index' do
      include_context 'daily index'

      it { is_expected.to be_falsey }
    end

    context 'with a monthly index' do
      include_context 'monthly index'

      it { is_expected.to be_truthy }
    end

    context 'with a yearly index' do
      include_context 'yearly index'

      it { is_expected.to be_falsey }
    end
  end

  describe '#daily?' do
    subject { index.daily? }

    context 'with a daily index' do
      include_context 'daily index'

      it { is_expected.to be_truthy }
    end

    context 'with a monthly index' do
      include_context 'monthly index'

      it { is_expected.to be_falsey }
    end

    context 'with a yearly index' do
      include_context 'yearly index'

      it { is_expected.to be_falsey }
    end
  end

  describe '#start_date' do
    subject { index.start_date }

    context 'with a daily index' do
      include_context 'daily index'

      it { is_expected.to eq(DateTime.new(2020, 4, 13, 0, 0, 0)) }
    end

    context 'with a monthly index' do
      include_context 'monthly index'

      it { is_expected.to eq(DateTime.new(2020, 4, 1, 0, 0, 0)) }
    end

    context 'with a yearly index' do
      include_context 'yearly index'

      it { is_expected.to eq(DateTime.new(2020, 1, 1, 0, 0, 0)) }
    end
  end

  describe '#end_date' do
    subject { index.end_date }

    context 'with a daily index' do
      include_context 'daily index'

      it { is_expected.to eq(DateTime.new(2020, 4, 14, 0, 0, 0)) }
    end

    context 'with a monthly index' do
      include_context 'monthly index'

      it { is_expected.to eq(DateTime.new(2020, 5, 1, 0, 0, 0)) }
    end

    context 'with a yearly index' do
      include_context 'yearly index'

      it { is_expected.to eq(DateTime.new(2021, 1, 1, 0, 0, 0)) }
    end
  end
end
