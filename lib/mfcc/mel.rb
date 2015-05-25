module Mfcc
  module Mel
    def mel(data)
      Mfcc.mel(data, filter_banks)
    end

    def filter_banks
      @filter_banks ||= Mfcc::FilterBanks.new(mel_filters_length, fft_size, sample_rate)
    end
  end

  def self.mel(data, filter_banks)
    filter_banks.process(data)
  end

  class FilterBanks
    attr_reader :filters, :fft_size, :samplerate, :range
    def initialize(filters = 20, fft_size = 512, samplerate = 16_000, lowfreq = 0, highfreq = nil)
      @filters = filters
      @fft_size = fft_size
      @samplerate = samplerate
      @range = lowfreq..(highfreq || (samplerate / 2))
    end

    def process(fft)
      (0..filters).map { |n| fft.zip(bank[n]).reject { |(_, b)| b.nil? }.inject(0) { |memo, (a, b)| memo + a * b } }
    end

    def bank(i)
      lower = fft_frequencies.map { |x| (x - mel_frequencies[i]) / (mel_frequencies[i + 1] - mel_frequencies[i]).to_f }
      upper = fft_frequencies.map { |x| (mel_frequencies[i + 2] - x) / (mel_frequencies[i + 2] - mel_frequencies[i + 1]).to_f }

      (0..(fft_size / 2)).map { |n| [0, [lower[n], upper[n]].min].max }
    end

    def r(i)
      mel_frequencies[i]
    end

    def to_hz(mel)
      700 * (10**(mel / 2595.0) - 1)
    end

    def to_mel(hz)
      2595 * Math.log10(1 + hz / 700.0)
    end

    def mel_frequencies
      @mel_frequencies ||= range.step(mel_step).to_a
    end

    def mel_step
      ((range.end - range.begin) / filters)
    end

    def fft_frequencies
      @fft_frequencies ||= [0] + (fft_size / 2).times.map { |i| (i + 1) * (samplerate / fft_size.to_f) }
    end
  end
end
