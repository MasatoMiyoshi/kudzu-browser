# frozen_string_literal: true

RSpec.describe Kudzu::Browser::Config do
  it "has a headless browser configuration" do
    expect(Kudzu::Config::SIMPLE_CONFIGS.include?(:browser)).to eq(true)
    expect(Kudzu::Config::DEFAULT_CONFIG[:browser]).to eq(false)
    expect(Kudzu::Crawler.new.config.browser).to eq(false)
    expect(Kudzu::Crawler.new(browser: true).config.browser).to eq(true)
  end
end
