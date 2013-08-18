module Halffare
  # More accurate price strategy
  #
  # Uses a static table for price conversions, falling back on
  # guess strategy if no entry found
  class PriceSbb < PriceBase
    def initialize(halffare)
      super(halffare)

      @table = YAML.load_file('price_sbb.yml')
      p @table
    end

    def get(order)
      return 0, 0
    end
  end
end
