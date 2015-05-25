require 'spec_helper'
require 'prime'
require 'timeout'

describe Mfcc do
  it 'has a version number' do
    expect(Mfcc::VERSION).not_to be nil
  end

  describe '#map' do
    it 'is lazy' do
      Timeout.timeout(15) { Mfcc::Calculator.new(Prime.lazy).map.take(1) }
    end
  end

  describe '.preemphasis' do
    it 'is an identity function if the pre-emphasis is 0' do
      expect(Mfcc.preemphasis([0, 2, 4, 6, 4, 6], 0)).to eq [0, 2, 4, 6, 4, 6]
    end
    it 'does something useful' do
      expect(Mfcc.preemphasis([0, 2, 4, 5], 0.97).to_a).to eq [0.0, 2.0, 2.06, 1.12]
    end
  end

  describe '.frame' do
    it 'slices an array into frames of a given size' do
      expect(Mfcc.frame(('a'..'z').to_a, 8, 5).to_a).to eq [
        %w(a b c d e f g h),
        %w(f g h i j k l m),
        %w(k l m n o p q r),
        %w(p q r s t u v w),
        %w(u v w x y z) + [0, 0],
        %w(z) + [0, 0, 0, 0, 0, 0, 0]
      ]
    end
  end

  describe '.hamming' do
    it 'rolls off either side' do
      data = Array.new(101) { 500 }
      actual = Mfcc.hamming(data).to_a
      expect(actual.first).not_to eq 500
      expect(actual.first).to eq actual.last
      expect(actual[50]).to eq 500
    end
  end

  describe '.dft' do
    it 'is 0 for DC' do
      data = Array.new(256) { 0 }
      actual = Mfcc.dft(data)
      expect(actual.all? { |a| a.real == 0 }).to eq true
    end

    it 'is 1 for sin(i)' do
      data = Array.new(64) { |i| 100 * Math.sin(2 * Math::PI * i / 64) }
      actual = Mfcc.dft(data)
      _, freq = actual.map(&:magnitude).each_with_index.max_by { |(v, _)| v }
      expect(freq).to eq 1
    end

    it 'is 4 for sin(4i)' do
      data = Array.new(64) { |i| 100 * Math.sin(4 * 2 * Math::PI * i / 64) }
      actual = Mfcc.dft(data)
      _, freq = actual.map(&:magnitude).each_with_index.max_by { |(v, _)| v }
      expect(freq).to eq 4
    end
  end

  describe '.dct' do
    it 'is the average for a line at order 1' do
      data = [10, 12, 15, 14, 13, 11, 9, 1, -5, -3, 1, 2, 5, 4, 2, -2]
      actual = Mfcc.dct(data, 16).map { |x| x.round(8) }

      expect(actual).to eq [22.25,  19.06842855,   8.1637363,  -5.65967557,
                            -11.28751151,   4.37311854,  -0.23718664,  -1.98752424,
                            -3.25,   1.48643374,   1.2417047,  -0.57125717,
                            -0.4659226,   1.08099314,  -0.07294932,   1.04130718]
    end
  end
end
