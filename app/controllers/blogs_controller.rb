class BlogsController < ApplicationController
    protect_from_forgery with: :null_session

    before_action :authorize_request

    def create
        blog= @current_user.blogs.new(blog_params)

        if blog.save
            render json: {message: "Blog creation successful", blog: blog}, status: :created
        else
            render json: {errors: blog.errors.full_messages }, status: :unprocessable_entity
        end

    end

    private
    
    def blog_params
        params.require(:blog).permit(:title, :content)
    end

end
