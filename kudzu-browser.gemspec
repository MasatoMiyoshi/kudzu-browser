# frozen_string_literal: true

require_relative "lib/kudzu/browser/version"

Gem::Specification.new do |spec|
  spec.name = "kudzu-browser"
  spec.version = Kudzu::Browser::VERSION
  spec.authors = ["Masato Miyoshi"]
  spec.email = ["miyoshi@sitebridge.co.jp"]

  spec.summary = "Headless browswer agent for kudzu crawler"
  spec.description = "Headless browswer agent for kudzu crawler"
  spec.homepage = "https://github.com/MasatoMiyoshi/kudzu-browser"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "kudzu"
  spec.add_dependency "ferrum"
  spec.add_dependency "addressable"
  spec.add_dependency "http-cookie"

  spec.add_development_dependency "rails"
  spec.add_development_dependency "webrick"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "simplecov"
end
