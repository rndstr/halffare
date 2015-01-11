module Halffare
  class Stats

    # Reads orders from `filename` that date back to max `months` months.
    #
    # @param filename [String]       The filename to read from
    # @param months   [Integer, nil] Number of months look back or nil for all
    def read(filename, months=nil)
      @orders = []
      start = months ? (Date.today << months.to_i).strftime('%Y-%m-%d') : nil
      file = File.open(filename, "r:UTF-8") do |f|
        while line = f.gets
          order = Halffare::Model::Order.new(line)
          if (start.nil? || line[0,10] >= start) && (order.note != Fetch::ORDER_NOTE_FILE_CREATED)
            @orders.push(order)
          end
        end
      end
      log_info "read #{@orders.length} orders from #{filename}"
      if @orders.length == 0
        if start.nil?
          log_notice "no orders found"
        else
          log_notice "no orders found after #{start}, maybe tweak the --months param"
        end
      end
    end

    # How many orders were processed.
    def count
      @orders.length
    end

    # Calculates prices according to given strategy.
    #
    # @param strategy [String] Strategy name
    # @param halffare [true, false] True if tickets were bought with a halffare card
    def calculate(strategy, halffare)
      @halfprice = 0
      @fullprice = 0

      if halffare
        log_info "assuming order prices as half-fare"
      else
        log_info "assuming order prices as full"
      end

      log_notice "please note that you are using a strategy that involves guessing the real price" if ['guess', 'sbbguess'].include? strategy

      strategy = price_factory(strategy)
      strategy.halffare = halffare
      log_info "using price strategy: #{strategy.class}"
      price = Price.new(strategy)
      log_info "calculating prices..."

      @date_min = false
      @date_max = false
      @orders.each do |order|

        if Halffare.debug
          log_order(order)
        end

        halfprice, fullprice = price.get(order)

        if Halffare.debug
          if halfprice != 0 && fullprice != 0
            log_result "FOUND: #{order.description} (#{order.price}): half=#{currency(halfprice)}, full=#{currency(fullprice)}"

            if halffare
              log_emphasize "You would pay (full price): #{currency(fullprice)}, you save #{currency(fullprice - order.price)}"
            else
              log_emphasize "You would pay (half-fare): #{currency(halfprice)}, you pay #{currency(order.price - halfprice)} more"
            end
          end
        end

        @halfprice += halfprice
        @fullprice += fullprice

        @date_min = order.travel_date if !@date_min || order.travel_date < @date_min
        @date_max = order.travel_date if !@date_max || order.travel_date > @date_max
      end
    end

    # Load config file.
    def config
      @config ||= YAML.load_file(File.expand_path('../../../halffare.yml', __FILE__))
    end

    def display(halffare)
      say("\n")
      days = (Date.parse(@date_max) - Date.parse(@date_min)).to_i
      paid = halffare ? @halfprice : @fullprice
      paid_per_day = paid / days
      fullprice_per_day = @fullprice / days
      saved_per_day = (@fullprice - @halfprice) / days

      log_info "Results"
      log_info "======="
      say("\n")
      log_info "OVERALL"
      log_info "orders: #{@orders.length}"
      log_info "first travel date: #{@date_min}"
      log_info "last travel date : #{@date_max} (#{days} days)"
      log_info "half-fare price  : #{currency(@halfprice)}#{halffare ? ' (what you paid)':''}"
      log_info "full price       : #{currency(@fullprice)}#{halffare ? '' : ' (what you paid)'}"
      log_info "half-fare savings: #{currency(@fullprice - @halfprice)}"
      say("\n")
      log_info "PER DAY"
      log_info "you pay          : #{currency(paid_per_day)}"
      log_info "half-fare savings: #{currency(saved_per_day)}"

      say("\n")
      log_info "Half-Fare Card"
      log_info "-------------"

      config['cards'].each do |months,cash|
        say("\n")
        years = months/12
        saved = saved_per_day * years * 365
        log_info "#{years} YEAR#{years == 1 ? '' : 'S'} #{currency(cash)}"
        log_info "you pay          : #{currency(paid_per_day * years * 365)}"
        log_info "full price       : #{currency(fullprice_per_day * years * 365)}"
        log_info "half-fare savings: #{currency(saved)}"
        if saved >= cash
          say("<%= color('GOOD TO GO', WHITE, BOLD, ON_GREEN) %> (#{currency((saved - cash) / years)} net win per year)")
        else
          say("<%= color('NAY', WHITE, BOLD, ON_RED) %> (#{currency((cash - saved) / years)} net loss per year)")
        end
      end

      if fullprice_per_day * 365 > 2500
        say("\n")
        log_result "Since your tickets would cost approximately #{currency(fullprice_per_day * 365)} per year (w/o half-fare card) you should check out the GA prices for your age bracket: http://www.sbb.ch/abos-billette/abonnemente/ga/preise.html"
      end
    end

    private
    def price_factory(strategy)
      case strategy.to_s
      when "guess"
        Halffare::PriceGuess.new
      when "sbb"
        Halffare::PriceSbb.new
      when "sbbguess"
        Halffare::PriceSbb.new(true)
      else
        raise "unknown strategy: #{strategy}"
      end
    end

  end
end

