# encoding: binary
module Halffare
  # More accurate price strategy
  #
  # Uses a static table for price conversions, falling back on
  # guess strategy if no entry found
  class PriceSbb < PriceBase
    def initialize(halffare)
      super(halffare)

      @rules = YAML.load_file('price_sbb.yml')
      p @rules
    end

    def get(order)
      @rules.each { |rule|
        rule.each { |match, definition|
          if order.description =~ /#{match}/u
            if definition['scale'] != nil
              if @halffare
                return definition['scale']['half'][0] * order.price, definition['scale']['half'][1] * order.price
              else
                return definition['scale']['full'][0] * order.price, definition['scale']['full'][1] * order.price
              end
            elsif definition['set'] != nil
              if @halffare && order.price != definition['set']['half']
                puts "WARNING: order matched but price differs"
                p order
              elsif !@halffare && order.price != definition['set']['full']
                puts "WARNING: order matched but price differs"
              else
                return definition['set']['half'], definition['set']['full']
              end
            end
          end
        }
      }
      puts "ERROR: no satisfying match found for order, ignoring"
      p order
      return 0, 0
    end
  end
end
