# frozen_string_literal: true

module Kudzu
  module Browser
    class Util
      class ContentDisposition
        class AttachmentParser
          attr_reader :filename, :save_path

          def initialize(data, url, save_path)
            @filename = parse_filename_with_encoding(data)
            @filename ||= parse_filename_without_encoding(data)
            @filename ||= url_basename(url)
            @save_path = save_path
          end

          def parse_filename_with_encoding(data)
            md = data.match(/filename\*=(.+)'.*'["]?([^"]+)["]?[;]?/)
            return nil if md.nil?

            begin
              Addressable::URI.unencode(md[2].force_encoding('utf-8').encode('utf-8', invalid: :replace, undef: :replace))
            rescue
              nil
            end
          end

          def parse_filename_without_encoding(data)
            md = data.match(/filename=["]?([^"]+)["]?[;]?/)
            md.nil? ? nil : md[1]
          end

          def url_basename(url)
            uri = Addressable::URI.parse(url)
            uri.basename
          end

          def file_exist?
            File.exist?(full_path)
          end

          def body
            return nil unless file_exist?
            File.binread(full_path)
          end

          private

          def full_path
            File.join([save_path, filename])
          end
        end
      end
    end
  end
end
