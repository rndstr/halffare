require 'mechanize'
require 'highline/import'
require 'logger'
require 'date'
require 'yaml'

require 'halffare/version.rb'
require 'halffare/fetch.rb'
require 'halffare/stats.rb'
require 'halffare/model/order.rb'
require 'halffare/price.rb'
require 'halffare/price_base.rb'
require 'halffare/price_guess.rb'
require 'halffare/price_sbb.rb'

module Kernel
  private
  def currency(cash)
    'CHF' + sprintf('%.2f', cash.to_f.abs)
  end

  def log_debug(str)
    say(str) if Halffare.debug
  end

  def log_info(str)
    say("#{str}")
  end

  def log_notice(str)
    say("<%= color('#{str.gsub("'","\\\\'")}', BOLD) %>")
  end

  def log_heading(str)
    say("<%= color('#{str.gsub("'","\\\\'")}', YELLOW, BOLD) %>")
  end

  def log_result(str)
    say("<%= color('#{str.gsub("'","\\\\'")}', GREEN) %>")
  end

  def log_emphasize(str)
    say("<%= color('#{str.gsub("'","\\\\'")}', CYAN) %>")
  end

  def log_error(str)
    say("<%= color('#{'ERROR: ' + str.gsub("'","\\\\'")}', WHITE, ON_RED, BOLD) %>")
  end

  def log_order(order)
    log_info "\n"
    log_heading "#{order.order_date} #{order.description}"
    log_emphasize "You paid: #{currency(order.price)}"
  end

  def yesno(prompt = 'Continue?', default = true)
    a = ''
    s = '[y/n]'
    unless default.nil?
      s = default  ? '[Y/n]' : '[y/N]'
    end
    d = default ? 'y' : 'n'
    until %w[y n].include? a
      a = ask("#{prompt} #{s}  ") { |q| q.limit = 1; q.case = :downcase }
      a = d if a.length == 0
    end
    a == 'y'
  end
end
