module Halffare
  module Model
    class Order
      SEPARATOR = '::'

      attr_reader :travel_date, :order_date, :price, :note, :description, :user
      attr_writer :price

      def initialize(row)
        from_row(row)
      end

      def from_row(row)
        @travel_date, @order_date, @price, @note, @description, @user = row.split("|")
        @description.strip!
        @price = @price.to_f
      end

      def has_user?(user)
        @user.include?(SEPARATOR + @user + SEPARATOR)
      end

      def user_count
        @user.count(SEPARATOR) - 1
      end
    end
  end
end
