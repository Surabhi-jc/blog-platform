class BlogsController < ApplicationController
    protect_from_forgery with: :null_session

    before_action :authorize_request


    skip_before_action :authorize_request, only: [:show, :show_blog]



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
        blogs=Blog.includes(:user, :tags).order(created_at: :desc)
        render json: blogs.map {|blog|
            {
              id: blog.id,
              title: blog.title,
              content: blog.content,
              author_name: blog.user.name,
              tags: blog.tags.map(&:name),
              likes_count: blog.likes_count,
              created_at: blog.created_at
            }
        }, status: :ok
    end

    def show_blog
        blog=Blog.includes(:user, :tags, comments: :user).find_by(id: params[:id])
        if blog
        render json: {

              id: blog.id,
              title: blog.title,
              content: blog.content,
              author_name: blog.user.name,
              tags: blog.tags.map(&:name),
              likes_count: blog.likes_count,
              created_at: blog.created_at,
              comments: blog.comments.where(parent_comment_id: nil).map do |comment|
                serialize_comment(comment)
              end
            }, status: :ok
        else
            render json: {error: "Blog not found"}, status: :not_found
        end

    end

    def my_blogs
      blogs = @current_user.blogs.includes(:tags).order(created_at: :desc)
      render json: blogs.map { |blog|
        {
          id: blog.id,
          title: blog.title,
          content: blog.content,
          author_name: blog.user.name,
          tags: blog.tags.map(&:name),
          likes_count: blog.likes_count,
          created_at: blog.created_at
        }
      }, status: :ok
    end

    def update
      blog = Blog.find_by(id: params[:id])
      return render json: { error: "Blog not found" }, status: :not_found unless blog

      if blog.user_id != current_user.id
            render json: {error: "Not authorized to update this blog"}, status: :unauthorized
        elsif blog.update(blog_params)
        render json: {message: "Blog updation success", blog: blog}, status: :ok
        else
            render json: {errors: blog.errors.full_messages}, status: :unprocessable_entity
        end
    end

    def destroy
      blog = Blog.find_by(id: params[:id])
      return render json: { error: "Blog not found" }, status: :not_found unless blog

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

        p_blogs= Blog.includes(:user, :tags).joins(:tags).where(tags: {id: p_tags}).distinct

        other_blogs= Blog.includes(:user, :tags).where.not(id: p_blogs.pluck(:id))

        blogs= p_blogs + other_blogs

        formatted_blogs = blogs.map do |blog|
            {
              id: blog.id,
              title: blog.title,
              content: blog.content,
              author_name: blog.user.name,               # blog belongs_to :user
              tags: blog.tags.map(&:name)                # blog has_many :tags
            }
        end

        render json: { blogs: formatted_blogs }, status: :ok
    end

    def is_liked
        blog = Blog.find_by(id: params[:id])
        return render json: { liked: false }, status: :not_found unless blog

        liked = Like.exists?(user_id: @current_user.id, blog_id: blog.id)

        render json: { liked: liked }
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

    def serialize_comment(comment)
      {
        id: comment.id,
        content: comment.content,
        user_name: comment.user.name,
        created_at: comment.created_at,
        replies: comment.replies.map { |reply| serialize_comment(reply) }
      }
    end

end
