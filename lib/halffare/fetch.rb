module Halffare

  class Fetch
    USER_AGENT = 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.11 (KHTML, like Gecko) Chrome/23.0.1271.64 Safari/537.11'
    URL_LOGIN = 'http://www.sbb.ch/meta/login.html'
    URL_ORDERS = 'https://www.sbb.ch/ticketshop/b2c/dossierListe.do'
    ORDER_NOTE_FILE_CREATED = 'halffare-orders-file-created'
    SEPARATOR = '::'

    def initialize()
      @agent = ::Mechanize.new
      @agent.user_agent = USER_AGENT
    end

    def login(username, password)
      username = ask("sbb.ch username?  ") unless username
      password = ask("sbb.ch password?  ") { |q| q.echo = "*" } unless password
      log_info "logging in..."

      #@agent.log = Logger.new('debug.log')

      @response = @agent.get URL_LOGIN

      login = @response.forms.first
      login['logon.username'] = username
      login['logon.password'] = password

      @response = @agent.submit(login)
    end

    def download(filename, pages, months)
      @response = @agent.get URL_ORDERS

      logged_in!

      begin
        left = pages.to_i
        page = 1
        stop_after = months ? (Date.today << months.to_i).strftime('%Y-%m-%d') : nil

        log_info "will stop scraping after reaching #{stop_after}" unless stop_after.nil?
        log_info "writing data to #{filename}"

        file = File.open(filename, "w")
        oldest_date_on_page = Date.today.strftime

        # fake entry so when evaluating this file the calculation goes up until today
        # and not to the last order.
        file.write "#{oldest_date_on_page}|#{oldest_date_on_page}|0|#{ORDER_NOTE_FILE_CREATED}||\n"

        loop do
          print ">>> page #{page}/#{pages} "
          orders do |idx, travel_date, order_date, price, note, description, user|
            print "."

            travel_date = Date.parse(travel_date).strftime
            order_date = Date.parse(order_date).strftime
            oldest_date_on_page = [order_date, oldest_date_on_page].min

            file.write "#{travel_date}|#{order_date}|#{price}|#{note}|#{description}|#{user}\n" if stop_after.nil? || travel_date >= stop_after
          end
          puts
          next!

          log_debug "oldest order on page was on #{oldest_date_on_page}" if Halffare.debug

          page += 1
          left -= 1

          break if !stop_after.nil? && oldest_date_on_page < stop_after
          break if left <= 0
        end
      rescue IOError => e
        puts e
      ensure
        file.close unless file == nil
      end
    end

    private
    def orders
      @response.search('#orders tbody tr').each do |order|
        idx = order.attr('id').split('-')[1]
        order_date = order.xpath('./td[1]').text.gsub(/[[:space:]]/, ' ').strip
        travel_date = order.xpath('./td[2]').text.gsub(/[[:space:]]/, ' ').strip
        price = order.xpath('./td[4]').text.gsub(/[[:space:]]/, ' ').strip
        note = order.xpath('./td[5]').text.gsub(/[[:space:]]/, ' ').strip

        description = ''
        user = ''

        @response.search('#bezeichnungen tr#ordersBezeichnung-' + idx + ' td ul').each { |ul|
          ul.to_s.scan(/<li>(.*)<br>(.*)<\/li>/) do |d,u|
            description << SEPARATOR << d.gsub(/[[:space:]]/, ' ').strip
            user << SEPARATOR << u.gsub(/[[:space:]]/, ' ').strip
          end
        }
        description << SEPARATOR
        user << SEPARATOR

        yield idx, order_date, travel_date, price, note, description, user if block_given?
      end
    end

    def next!
      @response = @response.forms_with(:action => '/ticketshop/b2c/dossierListe.do').first
      @response = @response.submit(@response.button_with(:name => 'method:more'))
    end

    def logged_in!
      error = @response.at '.skinMessageBoxError'
      if error != nil
        STDERR.puts "ERROR: Not logged in, verify your username and password"
        exit 1
      end
    end
  end
end
