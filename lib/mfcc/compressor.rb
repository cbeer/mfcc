module Mfcc
  module Compressor
    def compress(data)
      Mfcc.compress(data)
    end
  end

  LOG10_ERROR_VALUE = -0.00000001

  def self.compress(data)
    return to_enum(:compress, data) { data.size } unless block_given?

    data.each do |d|
      v = if d == 0
            LOG10_ERROR_VALUE
          else
            Math.log10(d)
          end

      yield v
    end
  end
end
