# frozen_string_literal: true

RSpec.describe Kudzu::Browser::Util::ContentDisposition::AttachmentParser do
  let(:save_path) { "#{File.expand_path(__dir__)}/../../../../fixture/files/" }

  context '#filename' do
    it 'parses' do
      parser = Kudzu::Browser::Util::ContentDisposition::AttachmentParser.new(
        'attachment; filename=sample.jpg',
        'http://example.com/files/sample.jpg',
        save_path
      )
      expect(parser.filename).to eq('sample.jpg')
    end

    it 'parses when filename is quoted' do
      parser = Kudzu::Browser::Util::ContentDisposition::AttachmentParser.new(
        'attachment; filename="sample.jpg"',
        'http://example.com/files/sample.jpg',
        save_path
      )
      expect(parser.filename).to eq('sample.jpg')
    end

    it 'parses when url is not include filename' do
      parser = Kudzu::Browser::Util::ContentDisposition::AttachmentParser.new(
        'attachment; filename="sample.jpg"',
        'http://example.com/files/test',
        save_path
      )
      expect(parser.filename).to eq('sample.jpg')
    end

    it 'parses when filename is none' do
      parser = Kudzu::Browser::Util::ContentDisposition::AttachmentParser.new(
        'attachment',
        'http://example.com/files/sample.jpg',
        save_path
      )
      expect(parser.filename).to eq('sample.jpg')
    end

    it 'parses when filename is encoded' do
      parser = Kudzu::Browser::Util::ContentDisposition::AttachmentParser.new(
        'attachment; filename="%3F%3F%3F.jpg"; filename*=UTF-8\'\'%E3%83%86%E3%82%B9%E3%83%88.jpg',
        'http://example.com/files/test',
        save_path
      )
      expect(parser.filename).to eq('テスト.jpg')
    end
  end

  context '#body' do
    it 'reads file' do
      parser = Kudzu::Browser::Util::ContentDisposition::AttachmentParser.new(
        'attachment; filename=sample.jpg',
        'http://example.com/files/sample.jpg',
        save_path
      )
      expect(parser.body.to_s.empty?).to eq(false)
    end

    it 'reads non-existent file' do
      parser = Kudzu::Browser::Util::ContentDisposition::AttachmentParser.new(
        'attachment; filename=test.jpg',
        'http://example.com/files/test.jpg',
        save_path
      )
      expect(parser.body.to_s.empty?).to eq(true)
    end
  end
end
