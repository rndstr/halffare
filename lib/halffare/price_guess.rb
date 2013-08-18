module Halffare
  # Simple guesstimator assuming half-fare card is always half the price
  # which is _not_ the case in reality
  class PriceGuess < PriceBase
    def get(order)
      price = order.price.to_f
      if @halffare
        return price, price*2
      else
        return price/2, price
      end
    end
  end
end
