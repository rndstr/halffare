module Halffare
  class Price
    def initialize (strategy)
      @strategy = strategy
    end

    def get(order)
      @strategy.get(order)
    end
  end
end
