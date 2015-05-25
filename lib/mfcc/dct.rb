module Mfcc
  # Takes the discrete cosing transform.  Converts an n x m matrix to an n x
  # order matrix.  ncol should be set to m.
  module Dct
    def dct(data)
      Mfcc.dct(data, dct_order)
    end
  end

  def self.dct(data, order = 13, orthogonalize = true)
    length = data.size

    scales = if orthogonalize
               [Math.sqrt(1.0 / (4 * length)), Math.sqrt(1.0 / (2 * length))]
             else
               [1, 1]
             end

    dct_matrix(order, length).each_with_index.map do |row, index|
      scale = index == 0 ? scales[0] : scales[1]
      scale * row.zip(data).inject(0) { |memo, (a, b)| memo + (2 * a * b) }
    end
  end

  def self.dct_matrix(n, m)
    n.times.map do |i|
      freq = (Math::PI * i) / m
      m.times.map do |j|
        Math.cos(freq * (j + 0.5))
      end
    end
  end
end
