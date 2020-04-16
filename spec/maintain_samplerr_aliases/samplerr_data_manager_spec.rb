require 'timecop'
require 'maintain_samplerr_aliases'

RSpec.describe MaintainSamplerrAliases::SamplerrDataManager do
  subject do
    described_class.new(3, 2, 10)
  end

  %w[1970 2019 2020 2020_02 2020_03 2020_04 2020_04_08 2020_04_09 2020_04_10 2020_04_11].each do |index_date|
    let("index_#{index_date}") { MaintainSamplerrAliases::SamplerrData::Index.new('index' => ".samplerr-#{index_date.tr('_', '.')}") }
  end

  before do
    Timecop.freeze(DateTime.new(2020, 4, 11, 13, 13, 26))

    allow(MaintainSamplerrAliases::SamplerrData.instance).to receive(:indices).and_return(
      [
        index_1970,
        index_2019,
        index_2020,
        index_2020_02,
        index_2020_03,
        index_2020_04,
        index_2020_04_08,
        index_2020_04_09,
        index_2020_04_10,
        index_2020_04_11,
      ]
    )
  end

  after do
    Timecop.return
  end

  describe '#expired_indices' do
    it 'returns expired indices' do
      expect(subject.send(:expired_indices)).to eq([index_1970, index_2020_02, index_2020_04_08])
    end
  end
  describe '#expired_dayy_indices' do
    it 'returns an expired index' do
      expect(subject.send(:expired_daily_indices)).to eq([index_2020_04_08])
    end
  end
  describe '#expired_monthly_indices' do
    it 'returns an expired index' do
      expect(subject.send(:expired_monthly_indices)).to eq([index_2020_02])
    end
  end
  describe '#expired_yearly_indices' do
    it 'returns an expired index' do
      expect(subject.send(:expired_yearly_indices)).to eq([index_1970])
    end
  end
end
