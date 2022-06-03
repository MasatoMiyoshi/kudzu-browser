# frozen_string_literal: true

module Kudzu
  module Browser
    class Util
      class ContentDisposition
        class << self
          def type_attachment?(data)
            return false if data.nil?
            data.start_with?('attachment')
          end
        end
      end
    end
  end
end
