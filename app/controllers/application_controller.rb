class ApplicationController < ActionController::API
  include ActionController::Cookies
  include ActionController::RequestForgeryProtection

  protect_from_forgery with: :exception

  private

  def set_csrf_token
    cookies['X-CSRF-Token'] = {
      value: form_authenticity_token,
      httponly: true
    }
    # cookies['X-CSRF-Token'] = form_authenticity_token
    # cookies['X-CSRF-Token'] = {
    #   domain: 'http://localhost:3001/', # 親ドメイン
    #   token: form_authenticity_token,
    #   same_site: :strict
    # }
  end
end