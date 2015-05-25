module Mfcc
  module Hamming
    def hamming(data)
      Mfcc.hamming(data, alpha)
    end
  end

  def self.hamming(data, alpha = 0.46)
    return to_enum(:hamming, data, alpha) { data.size } unless block_given?

    beta = 1 - alpha
    length = data.size

    data.each_with_index do |d, i|
      yield d * h(alpha, beta, length, i)
    end
  end

  def self.h(alpha, beta, size, i)
    alpha - beta * Math.cos(2 * Math::PI * i / (size - 1))
  end
end
