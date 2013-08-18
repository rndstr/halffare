module Halffare
  class PriceBase
    def initialize(halffare)
      @halffare = halffare
    end

    def get(order)
      raise 'you need to implement get in your price strategy'
    end
  end
end
