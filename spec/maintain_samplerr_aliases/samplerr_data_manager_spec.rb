require 'timecop'
require 'maintain_samplerr_aliases'

RSpec.describe MaintainSamplerrAliases::SamplerrDataManager do
  subject do
    described_class.new(3, 2, 10)
  end

  before do
    Timecop.freeze(DateTime.new(2020, 4, 11, 13, 13, 26))
  end

  after do
    Timecop.return
  end

  describe '#initialize' do
    it 'has the correct daily data start date' do
      expect(subject.daily_data_start).to eq(DateTime.new(2020, 4, 9))
    end
    it 'has the correct monthly data start date' do
      expect(subject.monthly_data_start).to eq(DateTime.new(2020, 3, 1))
    end
    it 'has the correct yearly data start date' do
      expect(subject.yearly_data_start).to eq(DateTime.new(2011, 1, 1))
    end
  end

  describe '#today' do
    it 'return the current date' do
      expect(subject.today).to eq(DateTime.new(2020, 4, 11))
    end
  end
end
