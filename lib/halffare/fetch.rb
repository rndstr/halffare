module Halffare

  class Fetch
    USER_AGENT = 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.11 (KHTML, like Gecko) Chrome/23.0.1271.64 Safari/537.11'
    URL_LOGIN = 'http://www.sbb.ch/meta/login.html'
    URL_ORDERS = 'https://www.sbb.ch/ticketshop/b2c/dossierListe.do'

    def initialize(debug)
      @debug = debug
      @agent = ::Mechanize.new
      @agent.user_agent = USER_AGENT
    end

    def login(username, password)
      username = ask("sbb.ch username?  ") unless username
      password = ask("sbb.ch password?  ") { |q| q.echo = "*" } unless password
      puts ">>> logging in..."

      @agent.log = Logger.new('debug.log') if @debug

      @response = @agent.get URL_LOGIN

      login = @response.forms.first
      login['logon.username'] = username
      login['logon.password'] = password

      @response = @agent.submit(login)
    end

    def download(filename, pages)
      @response = @agent.get URL_ORDERS

      logged_in!

      begin
        left = pages
        page = 1
        puts ">>> writing data to #{filename}"
        file = File.open(filename, "w")
        begin
          print ">>> page #{page}/#{pages} "
          orders do |idx, travel_date, order_date, price, note, name|
            print "."
            travel_date = Date.parse(travel_date).strftime
            order_date = Date.parse(order_date).strftime
            file.write "#{travel_date}|#{order_date}|#{price}|#{note}|#{name}\n"
          end
          puts
          next!

          page += 1
          left -= 1
        end while left > 0
      rescue IOError => e
        puts e
      ensure
        file.close unless file == nil
      end
      puts ">>> done."
    end

    private
    def orders
      @response.search('#orders tbody tr').each do |order|
        idx = order.attr('id').split('-')[1]
        order_date = order.xpath('./td[1]').text.gsub(/[[:space:]]/, ' ').strip
        travel_date = order.xpath('./td[2]').text.gsub(/[[:space:]]/, ' ').strip
        price = order.xpath('./td[4]').text.gsub(/[[:space:]]/, ' ').strip
        note = order.xpath('./td[5]').text.gsub(/[[:space:]]/, ' ').strip
        description = ""
        @response.search('#bezeichnungen tr#ordersBezeichnung-' + idx + ' td ul li').each { |i|
          description << "::" unless description.empty?
          description << i.text.gsub(/[[:space:]]/, ' ').strip
        }

        yield idx, order_date, travel_date, price, note, desription if block_given?
      end
    end

    def next!
      @response = @response.forms_with(:action => '/ticketshop/b2c/dossierListe.do').first
      @response = @response.submit(@response.button_with(:name => 'method:more'))
    end

    def logged_in!
      error = @response.at '.skinMessageBoxError'
      if  error != nil
        STDERR.puts "ERROR: Not logged in, verify your username and password"
        exit 1
      end
    end
  end
end
