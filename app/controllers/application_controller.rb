class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

protect_from_forgery with: :null_session

private
def authorize_request
        header= request.headers['Authorization']
        if header
            token=header.split[1]   #[bearer jwt]
            decoded= JsonWebToken.decode(token)
            @current_user= User.find_by(id: decoded[:user_id]) if decoded   #instance variable
            render json: {error: 'Unauthorized access, need to log in'}, status: :unauthorized unless @current_user
        end
    end

    def current_user
        @current_user
    end

end
