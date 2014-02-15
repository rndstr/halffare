module Halffare
  class PriceBase
    # @return halfprice, fullprice
    def get(order)
      raise 'you need to implement get(order) in your price strategy'
    end

    def halffare=(hf)
      @halffare = hf
    end

    private
    def price_paid
        @halffare ? 'half' : 'full'
    end
    def price_paid_other
        @halffare ? 'full' : 'half'
    end
  end
end
