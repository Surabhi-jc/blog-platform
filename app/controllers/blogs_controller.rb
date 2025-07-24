class BlogsController < ApplicationController
    protect_from_forgery with: :null_session

    before_action :authorize_request
    before_action :find_blog    

    skip_before_action :authorize_request, only: [:show, :show_blog]
    skip_before_action :find_blog, only: [:show, :create, :prefered_blogs]


    def create
        blog= @current_user.blogs.new(blog_params)

        if blog.save
            blog.tag_ids = blog_params[:tag_ids] if blog_params[:tag_ids]
            render json: {message: "Blog creation successful", blog: blog}, status: :created
        else
            render json: {errors: blog.errors.full_messages }, status: :unprocessable_entity
        end

    end

    def show
        blogs=Blog.includes(:user, :tags).all
        render json: blogs.map {|blog|
            {
              id: blog.id,
              title: blog.title,
              content: blog.content,
              author_name: blog.user.name,
              tags: blog.tags.map(&:name),
              created_at: blog.created_at
            }
        }, status: :ok
    end

    def show_blog
        blog=Blog.includes(:user, :tags).find_by(id: params[:id])
        if blog
        render json: {

              id: blog.id,
              title: blog.title,
              content: blog.content,
              author_name: blog.user.name,
              tags: blog.tags.map(&:name),
              created_at: blog.created_at
            }, status: :ok
        else
            render json: {error: "Blog not found"}, status: :not_found
        end

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

    #show user preferred blogs on the top
    def prefered_blogs
        p_tags= UserTag.where(user_id: @current_user.id).pluck(:tag_id)    #pluck-only tagid column from row

        p_blogs= Blog.joins(:tags).where(tags: {id: p_tags}).distinct

        other_blogs= Blog.where.not(id: p_blogs.pluck(:id))

        blogs= p_blogs + other_blogs

        render json: {blogs: blogs}, status: :ok
    end



    private

    def find_blog
        @blog= Blog.find_by(id: params[:id])
        unless @blog
            render json: { error: "Blog not found"}, status: :not_found
        end
    end
    
    def blog_params
        params.require(:blog).permit(:title, :content, tag_ids: [])
    end

end
