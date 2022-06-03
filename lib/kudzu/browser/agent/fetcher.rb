# frozen_string_literal: true

module Kudzu
  module Browser
    class Agent < Kudzu::Agent
      class Fetcher
        SAVE_PATH = '/tmp/kudzu_browser'.freeze

        attr_reader :browser

        def initialize(config, robots = nil)
          @config = config
          @sleeper = Kudzu::Agent::Sleeper.new(@config, robots)
          @filterer = Kudzu::Agent::PageFilterer.new(@config)
          @jar = HTTP::CookieJar.new
          @browser = build_browser
        end

        def fetch(url, request_header: {})
          uri = Addressable::URI.parse(url)
          headers = build_header(uri, request_header)
          response = send_request(uri, headers)
          build_response(response)
        end

        private

        def build_browser
          options = {
            'no-sandbox': nil,
            'disable-gpu': nil,
            'disable-dev-shm-usage': nil,
            'ignore-certificate-errors': nil,
          }
          Ferrum::Browser.new(headless: true,
                              save_path: SAVE_PATH,
                              browser_options: options)
        end

        def build_header(uri, request_header)
          headers = {}
          headers = append_basic_auth(uri.user, uri.password, headers) if uri.user && uri.password

          headers['User-Agent'] = @config.user_agent
          request_header.each do |key, value|
            headers[key] = value
          end
          headers
        end

        def create_page
          begin
            context = @browser.contexts.create
            page = context.create_page
            yield page
          ensure
            page.close
            context.dispose
          end
        end

        def send_request(uri, headers)
          res = {}
          create_page do |page|
            response, response_time = visit_url(uri, headers, page)
            raise Kudzu::Browser::NoResponseError.new("failed to request: #{uri.to_s}") if response.blank?

            res = { url: response.url,
                    status: response.status.to_i,
                    body: read_response_body(page, response),
                    response_header: response.headers,
                    response_time: response_time,
                    redirect_from: redirect_from(uri, response) }
          end
          res
        end

        def visit_url(uri, headers, page)
          page = append_cookie(uri, page) if @config.handle_cookie
          page.headers.set(headers)
          @sleeper.politeness_delay(uri)

          start = Time.now.to_f
          page.go_to(uri.to_s)
          page.network.wait_for_idle
          response = page.network.response
          response_time = Time.now.to_f - start

          parse_cookie(uri, page) if @config.handle_cookie
          return response, response_time
        end

        def redirect_from(uri, response)
          uri.to_s == response.url ? nil : uri.to_s
        end

        def build_response(response)
          fetched = @filterer.allowed_response_header?(response[:url], response[:response_header])
          Kudzu::Agent::Response.new(url: response[:url],
                                     status: response[:status],
                                     body: fetched ? response[:body] : nil,
                                     response_header: force_header_encoding(response[:response_header]),
                                     response_time: response[:response_time],
                                     redirect_from: response[:redirect_from],
                                     fetched: fetched)
        end

        def force_header_encoding(response_header)
          response_header.each do |key, value|
            response_header[key] = value.force_encoding('utf-8').encode('utf-8', invalid: :replace, undef: :replace)
          end
        end

        def redirection?(code)
          code = code.to_i
          300 <= code && code <= 399
        end

        def read_response_body(page, response)
          if Kudzu::Browser::Util::ContentDisposition.type_attachment?(response.headers['Content-Disposition'])
            parser = Kudzu::Browser::Util::ContentDisposition::AttachmentParser.new(
              response.headers['Content-Disposition'], response.url, SAVE_PATH)
            Kudzu.log :warn, "failed to read attachment: #{response.url}" unless parser.file_exist?
            parser.body.to_s
          else
            begin
              page.body.to_s
            rescue Ferrum::BrowserError => e
              parser = Kudzu::Browser::Util::ContentDisposition::AttachmentParser.new('', response.url, SAVE_PATH)
              Kudzu.log :warn, "failed to read attachment: #{response.url}" unless parser.file_exist?
              parser.body.to_s
            end
          end
        end

        def append_basic_auth(user, password, headers)
          bin = "#{user}:#{password}"
          headers['Authorization'] = "Basic #{Base64.encode64(bin)}"
          headers
        end

        def parse_cookie(uri, page)
          page.cookies.all.each do |name, cookie|
            @jar.parse(cookie_value(cookie), uri.to_s)
          end
        end

        def append_cookie(uri, page)
          cookies = @jar.cookies(uri.to_s)
          cookies.each do |cookie|
            page.cookies.set(name: cookie.name, value: cookie.value, domain: cookie.domain)
          end
          page
        end

        def cookie_value(cookie)
          values = ["#{cookie.name}=#{cookie.value}"]
          values << "Expires=#{cookie.expires}" if cookie.expires
          values << "Domain=#{cookie.domain}" if cookie.domain
          values << "Path=#{cookie.path}" if cookie.path
          values << "Secure" if cookie.secure?
          values << "HttpOnly" if cookie.httponly?
          values << "SameSite=#{cookie.samesite}" if cookie.samesite
          values.join('; ')
        end
      end
    end
  end
end
