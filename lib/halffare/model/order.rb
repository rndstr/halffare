module Halffare
  module Model
    class Order
      attr_reader :travel_date, :order_date, :price, :note, :description
      def initialize(row)
        from_row(row)
      end

      def from_row(row)
        @travel_date, @order_date, @price, @note, @description = row.split("|")
      end
    end
  end
end
