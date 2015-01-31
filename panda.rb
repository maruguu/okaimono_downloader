# okaimono panda downloader
# download 1 week (default) panda images
# usage: panda.rb <foldername> <startdate> <enddate>

require "date"
require "net/https"
require "uri"

class Panda
    attr_reader :foldername
    attr_reader :proxy_host
    attr_reader :proxy_port

    def initialize(folder)
        @foldername = folder || '.'
        @proxy_host, @proxy_port = (ENV["HTTP_PROXY"] || '').sub(/http:\/\//, '').split(':')
    end

    def download_from(from, to)
        puts "Download from " + from.to_s + " to " + to.to_s
        while from <= to do 
            download(from)
            sleep(Random.rand(4.0) + 0.5)
            from += 1
        end
    end

    def download(date)
        url = date.strftime("http://event.rakuten.co.jp/okaimonopanda/common/panda/%y%m%d/panda.png")
        puts url
        uri = URI.parse(url)
        proxy_class = Net::HTTP::Proxy(@proxy_host, @proxy_port)
        http = proxy_class.new(uri.host, uri.port)
        request = Net::HTTP::Get.new(uri.request_uri)
        response = http.request(request)
        if response.code != "200"
          STDERR.puts "HTTP get failed : code " + response.code
          return
        end
        filename = @foldername + "/" + date.strftime("panda%Y%m%d.png")
        begin
            open(filename, 'wb') do |file|
                file.puts response.body
            end
        rescue => ex
            STDERR.puts "writing " + url + " is failed : " + ex.message
        end
    end
end

panda = Panda.new(ARGV[0])
oneweekago = Date::today - 7
panda.download_from(Date.parse(ARGV[1] || oneweekago.to_s), Date.parse(ARGV[2] || Date::today.to_s))

