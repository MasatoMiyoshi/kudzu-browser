# frozen_string_literal: true

RSpec.describe Kudzu::Browser::Util::ContentDisposition do
  let(:attachment) { 'attachment; filename=sample.jpg' }
  let(:inline) { 'inline; filename=sample.jpg' }

  context '#type_attachment?' do
    it 'is attachment type' do
      expect(Kudzu::Browser::Util::ContentDisposition.type_attachment?(attachment)).to eq(true)
    end

    it 'is not attachment type' do
      expect(Kudzu::Browser::Util::ContentDisposition.type_attachment?(inline)).to eq(false)
    end
  end
end
