# frozen_string_literal: true

require "kudzu"
require "ferrum"
require "addressable"
require "http-cookie"

require_relative "browser/version"
require_relative "browser/agent"
require_relative "browser/config"
require_relative "browser/config/delegator"
require_relative "browser/util/content_disposition"
require_relative "browser/util/content_disposition/attachment_parser"

module Kudzu
  module Browser
    class NoResponseError < StandardError; end
  end
end

Kudzu::Config.include Kudzu::Browser::Config
Kudzu::Config::Delegator.include Kudzu::Browser::Config::Delegator
Kudzu.agent = Kudzu::Browser::Agent
