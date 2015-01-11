module Halffare
  class PriceBase

    # Extracts the prices from an order.
    #
    # @param order [Order] The order
    # @return halfprice, fullprice
    def get(order)
      raise 'you need to implement get(order) in your price strategy'
    end

    def halffare=(hf)
      @halffare = hf
    end

    private
    # Which price has been paid
    def price_paid
        @halffare ? 'half' : 'full'
    end

    # Opposite of {#price_paid}
    def price_paid_other
        @halffare ? 'full' : 'half'
    end
  end
end
