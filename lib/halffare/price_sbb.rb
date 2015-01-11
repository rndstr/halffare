# encoding: binary
module Halffare
  # More accurate price strategy
  #
  # Uses a static table for price conversions, falling back on
  # guess strategy if no entry found
  class PriceSbb < PriceGuess
    alias :price_guess_get :get

    def initialize(force_guess_fallback = false)
      @force_guess_fallback = force_guess_fallback
    end

    def get(order)
      log_debug "looking for an existing rule..."
      rules.each { |rule|
        rule.each { |match, definition|
          if order.description =~ /#{match}/u
            case
            when definition['scale'] != nil
              log_debug "found scale rule: #{definition}"
              return get_scale(definition, order)
            when definition['set'] != nil
              log_debug "found set rule: #{definition}"
              return get_set(definition, order)
            when definition['choices'] != nil
              log_debug "found choices rules: #{definition}"
              return get_choices(definition, order)
            end
          end
        }
      }
      log_result "no satisfying match found" if Halffare.debug
      return price_guess_get(order) if @force_guess_fallback

      ask_for_price(order)
    end

    private
    def rules
      @rules ||= YAML.load_file(File.expand_path('../pricerules_sbb.yml', __FILE__))
    end

    def get_scale(definition, order)
      return definition['scale'][price_paid][0] * order.price, definition['scale'][price_paid][1] * order.price
    end

    def get_set(definition, order)
      if order.price != definition['set'][price_paid]
        log_order(order)
        log_error 'order matched but price differs, ignoring'
        p order
        p definition
        return 0, 0
      else
        return definition['set']['half'], definition['set']['full']
      end
    end

    def get_choices(definition, order)
      # auto select
      definition['choices'].each { |name,prices| return prices['half'], prices['full'] if prices[price_paid] == order.price }

      return price_guess_get(order) if @force_guess_fallback

      choose do |menu|
        menu.prompt = "\nSelect the choice that applies to your travels?  "

        log_info "\n"
        definition['choices'].each do |name,prices|
          menu.choice "#{name} (half-fare: #{currency(prices['half'])}, full: #{currency(prices['full'])})" do
          end
        end
        menu.choice "…or enter manually" do ask_for_price(order) end
      end
    end

    def ask_for_price(order)
      guesshalf, guessfull = price_guess_get(order)

      if !Halffare.debug
        # was already logged
        log_order(order)
      end

      if @halffare
        other = ask("What would have been the full price?  ", Float) { |q| q.default = guessfull }
        return order.price, other
      else
        other = ask("What would have been the the half-fare price?  ", Float) { |q| q.default = guesshalf }
        return other, order.price
      end
    end

  end
end
