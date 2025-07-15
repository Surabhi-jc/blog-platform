class AuthenticationController < ApplicationController
    protect_from_forgery with: :null_session

    def login
        user=User.find_by(email: login_params[:email])

        if user&.authenticate(login_params[:password])
            token= encode_token({user_id: user.id})
            render json: {token: token, message: "Login successful"}, status: :ok
        else
            render json: {error: "Invalid email or password"}, status: :unauthorized
        end
    end

    private
    #JWT token generation
    def encode_token(payload)
        JWT.encode(payload, Rails.application.credentials.jwt_secret)
    end

    #allow only email, password
    def login_params
        params.permit(:email, :password)
    end


end
