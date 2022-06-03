class ApplicationController < ActionController::Base
  after_action :set_cookie

  def file
    render file: Rails.root.join('public/test/html1.html')
  end

  def not_modified
    render plain: '', status: 304
  end

  def gone
    render plain: '', status: 410
  end

  def internal_server_error
    render plain: '', status: 500
  end

  def image_file_jp
    send_file Rails.root.join('public/test/files/jpeg1.jpg'), filename: 'テスト.jpg'
  end

  def image_file_en
    send_file Rails.root.join('public/test/files/jpeg1.jpg'), filename: 'test.jpg'
  end

  def json
    render json: { html: '<ul><li><a href="http://localhost:9292/test/json.html">http://localhost:9292/test/json.html</a></li></ul>' }.to_json
  end

  private

  def set_cookie
    cookies[:test] = 'value'
  end
end
