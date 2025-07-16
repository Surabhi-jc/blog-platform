class BlogsController < ApplicationController
    protect_from_forgery with: :null_session

    before_action :authorize_request
    before_action :find_blog
    skip_before_action :authorize_request, only: [:show]
    skip_before_action :find_blog, only: [:show]


    def create
        blog= @current_user.blogs.new(blog_params)

        if blog.save
            render json: {message: "Blog creation successful", blog: blog}, status: :created
        else
            render json: {errors: blog.errors.full_messages }, status: :unprocessable_entity
        end

    end

    def show
        blogs=Blog.all
        render json: blogs, status: :ok
    end

    def update
        if @blog.user_id != current_user.id
            render json: {error: "Not authorized to update this blog"}, status: :unauthorized
        elsif @blog.update(blog_params)
        render json: {message: "Blog updation success", blog: @blog}, status: :ok
        else
            render json: {errors: @blog.errors.full_messages}, status: :unprocessable_entity
        end
    end

    def destroy
        if @blog.user_id != current_user.id
            render json: {error: "You are not authorized to delete this blog"}, status: :unauthorized
        elsif @blog.destroy
                render json: {message: "Blog deleted successfully"}, status: :ok
        else
                render json: {errors: @blog.errors.full_messages}, status: :unprocessable_entity
        end
    end




    private

    def find_blog
        @blog= Blog.find_by(id: params[:id])
        unless @blog
            render json: { error: "Blog not found"}, status: :not_found
        end
    end
    
    def blog_params
        params.require(:blog).permit(:title, :content)
    end

end
