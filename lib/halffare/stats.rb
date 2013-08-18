module Halffare
  class Stats

    def read(filename)
      @orders = []
      file = File.open(filename, "r", :encoding => "BINARY") do |f|
        while line = f.gets
          @orders.push(Halffare::Model::Order.new(line))
        end
      end
      puts ">>> read #{@orders.length} orders from #{filename}"
    end

    def calculate(strategy, halffare)
      @halfprice = 0
      @fullprice = 0

      if halffare
        puts ">>> assuming order prices as half-fare"
      else
        puts ">>> assuming order prices as full"
      end

      strategy_class = price_factory(strategy)
      puts ">>> using price strategy: #{strategy_class}"
      price = Price.new(strategy_class.new(halffare))
      puts ">>> calculating prices..."

      @date_min = false
      @date_min = false
      @orders.each do |order|
        halfprice, fullprice = price.get(order)
        @halfprice += halfprice
        @fullprice += fullprice

        @date_min = order.travel_date if !@date_min || order.travel_date < @date_min
        @date_max = order.travel_date if !@date_max || order.travel_date > @date_max
      end
    end

    def display
      puts
      puts "Results"
      puts ">>> orders: #{@orders.length}"
      puts ">>> first travel date: #{@date_min}"
      puts ">>> last  travel date: #{@date_max}"
      print ">>> half-farce price: "
      printf("%.2f", @halfprice)
      puts
      print ">>> full price      : "
      printf("%.2f", @fullprice)
      puts
      print ">>> possible savings: "
      printf("%.2f", @fullprice - @halfprice)
      puts
    end

    private
    def price_factory(strategy)
      case strategy
      when :guess
        Halffare::PriceGuess
      when :sbb
        Halffare::PriceSbb
      end
    end

  end
end

