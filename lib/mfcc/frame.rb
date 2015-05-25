module Mfcc
  module Frame
    def frame(data)
      Mfcc.frame(data, frame_size, frame_step)
    end
  end

  def self.frame(data, size, step)
    return to_enum(:frame, data, size, step) unless block_given?

    buffer = []

    data.each do |d|
      buffer.push(d)

      if buffer.size == size
        yield buffer

        buffer = buffer.slice(step..buffer.length)
      end
    end

    length = buffer.length

    (length / step.to_f).ceil.times do
      buffer.fill(0, buffer.size...size)

      yield buffer

      buffer = buffer.slice(step..buffer.length)
    end
  end
end
