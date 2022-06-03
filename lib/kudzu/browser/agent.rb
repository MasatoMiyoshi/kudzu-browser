# frozen_string_literal: true

require_relative "agent/fetcher"

module Kudzu
  module Browser
    class Agent < Kudzu::Agent
      def initialize(config, &block)
        @config = config

        @robots = Kudzu::Agent::Robots.new(@config)
        @fetcher = fetcher_class.new(@config, @robots)
        @url_extractor = Kudzu::Agent::UrlExtractor.new(@config)
        @url_filterer = Kudzu::Agent::UrlFilterer.new(@config, @robots)
        @page_filterer = Kudzu::Agent::PageFilterer.new(@config)
      end

      def start
        yield
        fetcher_close
      end

      def fetcher_class
        if @config.browser
          Kudzu::Browser::Agent::Fetcher
        else
          Kudzu::Agent::Fetcher
        end
      end

      def fetcher_close
        if @config.browser
          @fetcher.browser.quit
        else
          @fetcher.pool.close
        end
      end
    end
  end
end
