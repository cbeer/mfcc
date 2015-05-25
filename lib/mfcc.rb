require 'mfcc/version'

# MFCCs are commonly derived as follows:
#
# - Take the Fourier transform of (a windowed excerpt of) a signal.
# - Map the powers of the spectrum obtained above onto the mel scale, using triangular overlapping windows.
# - Take the logs of the powers at each of the mel frequencies.
# - Take the discrete cosine transform of the list of mel log powers, as if it were a signal.
# - The MFCCs are the amplitudes of the resulting spectrum.
# (http://en.wikipedia.org/wiki/Mel-frequency_cepstrum)
module Mfcc
  class Calculator
    require 'mfcc/preemphasis'
    require 'mfcc/frame'
    require 'mfcc/hamming'
    require 'mfcc/dft'
    require 'mfcc/mel'
    require 'mfcc/compressor'
    require 'mfcc/dct'

    include Mfcc::Preemphasis
    include Mfcc::Frame
    include Mfcc::Hamming
    include Mfcc::Dft
    include Mfcc::Mel
    include Mfcc::Compressor
    include Mfcc::Dct

    attr_reader :data, :options, :frame_size, :frame_step, :alpha, :emphasis,
                :mel_filters_length, :fft_size, :sample_rate, :dct_order

    def initialize(data, options = {})
      @data = data
      @frame_size = options.fetch(:frame_size, 400)
      @frame_step = options.fetch(:frame_step, 160)
      @alpha = options.fetch(:alpha, 0.46)
      @emphasis = options.fetch(:emphasis, 0.97)
      @mel_filters_length = options.fetch(:mel_filters_length, 20)
      @fft_size = options.fetch(:fft_size, 512)
      @sample_rate = options.fetch(:sample_rate, 16_000)
      @dct_order = options.fetch(:dct_order, 13)
    end

    def map
      return to_enum(:map) { self.data.size || Float::Infinity } unless block_given?

      data = preemphasis(self.data)

      data = frame(data)

      data = data.map do |frame|
        frame = hamming(frame)
        frame = dft(frame)
        frame = Mfcc.magnitude(frame)
        frame = compress(frame)
        frame = dct(frame)
        yield frame
      end
    end
  end
end
