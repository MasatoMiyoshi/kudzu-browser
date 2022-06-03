# frozen_string_literal: true

module Kudzu
  module Browser
    module Config
      module Delegator
        def browser(val)
          @config.browser = val
        end
      end
    end
  end
end
