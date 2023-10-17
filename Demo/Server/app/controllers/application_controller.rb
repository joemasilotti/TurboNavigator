class ApplicationController < ActionController::Base
  helper_method :turbo_native_app?

  before_action :basic_auth

  private

  def basic_auth
    authenticate_or_request_with_http_basic do |username, password|
      username == 'username' &&
        password == 'let-me-in'
    end
  end
end
