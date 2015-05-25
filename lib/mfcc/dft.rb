require 'complex'

module Mfcc
  module Dft
    def dft(data)
      Mfcc.dft(data)
    end
  end

  def self.dft(data)
    return to_enum(:dft, data) { data.size } unless block_given?

    n = data.size

    data = plus_imaginary(data)

    data.each_with_index do |_, k|
      sumreal = 0
      sumimag = 0

      data.each_with_index do |d, t|
        angle = 2 * Math::PI * t * k / n

        sumreal += d.real * Math.cos(angle) + d.imaginary * Math.sin(angle)
        sumimag += -1 * d.real * Math.sin(angle) + d.imaginary * Math.cos(angle)
      end

      yield Complex(sumreal, sumimag)
    end
  end

  def self.plus_imaginary(data)
    return to_enum(:plus_imaginary, data) { data.size } unless block_given?

    data.each do |d|
      yield case d
            when Complex
              d
            else
              Complex(d, 0)
            end
    end
  end

  def self.magnitude(data)
    return to_enum(:magnitude, data) { data.size } unless block_given?

    data.each do |d|
      yield d.respond_to?(:magnitude) ? d.magnitude : d
    end
  end
end
