module Mfcc
  module Preemphasis
    def preemphasis(data)
      Mfcc.preemphasis(data, emphasis)
    end
  end

  def self.preemphasis(data, emph = 0.97)
    return data if emph == 0

    return to_enum(:preemphasis, data, emph) { |d, _| d.size || Float::INFINITY } unless block_given?

    prev = 0

    data.each do |y|
      yield (y - emph * prev)
      prev = y
    end
  end
end
