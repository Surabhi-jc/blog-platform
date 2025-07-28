class UsersController < ApplicationController
protect_from_forgery with: :null_session

    def create
        user= User.new(user_params)

        if(user.save)
            token= JsonWebToken.encode({user_id: user.id})
            render json: {message: "User creation is successful", user: user, token: token}, status: :created
        else
            render json: {errors: user.errors.full_messages }, status: :unprocessable_entity
        end
    end

    private

    def user_params
        params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end


end
