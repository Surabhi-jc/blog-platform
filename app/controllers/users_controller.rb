class UsersController < ApplicationController
protect_from_forgery with: :null_session

before_action :authorize_request, only: [:me, :update]

    def create
        begin
        user= User.new(user_params)

        if user.save
            token= JsonWebToken.encode({user_id: user.id})
            render json: {message: "User creation is successful", user: user, token: token}, status: :created
        else
            render json: {errors: user.errors.full_messages }, status: :unprocessable_entity
        end

        rescue StandardError => e
            render json: { error: "Something went wrong: #{e.message}" }, status: :internal_server_error
        end
    end

def me
  render json: { id: @current_user.id, name: @current_user.name, email: @current_user.email, is_admin: @current_user.is_admin }
end

def update
  if @current_user&.update(user_params)
    render json: { id: @current_user.id, name: @current_user.name, email: @current_user.email }
  else
    Rails.logger.error @current_user.errors.full_messages.inspect
    render json: { error: @current_user.errors.full_messages }, status: :unprocessable_entity
    render json: { error: "Unable to update profile" }, status: :unprocessable_entity
  end
end

    private

    def user_params
        params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end


end
