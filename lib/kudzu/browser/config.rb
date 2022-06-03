# frozen_string_literal: true

module Kudzu
  module Browser
    module Config
      unless Kudzu::Config::SIMPLE_CONFIGS.include?(:browser)
        Kudzu::Config::SIMPLE_CONFIGS.push(:browser)
        Kudzu::Config::DEFAULT_CONFIG[:browser] = false
      end

      def browser
        @browser
      end

      def browser=(val)
        @browser = val
      end
    end
  end
end
