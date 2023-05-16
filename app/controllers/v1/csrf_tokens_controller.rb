module V1
  class CsrfTokensController < ApiController
    skip_before_action :check_authenticate!, raise: false

    def new
      render json: {
        csrf_token: set_csrf_token,
        # "cookies['X-CSRF-Token']": "#{cookies['X-CSRF-Token']}"
      }, status: 200
    end
  end
end