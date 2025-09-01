class BlogsController < ApplicationController
    protect_from_forgery with: :null_session

    before_action :authorize_request


    skip_before_action :authorize_request, only: [:show, :show_blog]



    def create
      begin
        blog = @current_user.blogs.new(blog_params)

        if blog.save
          blog.tag_ids = blog_params[:tag_ids] if blog_params[:tag_ids]

          response = { message: "Blog creation successful", blog: blog }
          status = :created
        else
          response = { errors: blog.errors.full_messages }
          status = :unprocessable_entity
        end

        render json: response, status: status
      rescue => e
        Rails.logger.error("Error creating blog: #{e.message}")
        render json: { error: "Failed to create blog" }, status: :internal_server_error
      end
    end


    def show
      begin
        blogs = Blog.active
                    .includes(:user, :tags)
                    .order(created_at: :desc)

        render json: blogs.map { |blog|
          {
            id: blog.id,
            title: blog.title,
            content: blog.content,
            author_name: blog.user.name,
            tags: blog.tags.map(&:name),
            likes_count: blog.likes_count,
            comments_count: blog.comments_count,
            created_at: blog.created_at
          }
        }, status: :ok
      rescue => e
        Rails.logger.error("Error fetching blogs: #{e.message}")
        render json: { error: "Failed to fetch blogs" }, status: :internal_server_error
      end
    end


    def show_blog
      begin
        blog=Blog.includes(:user, :tags, comments: :user).find_by(id: params[:id])
        if blog
          response= {

              id: blog.id,
              title: blog.title,
              content: blog.content,
              author_id: blog.user.id,
              author_name: blog.user.name,
              tags: blog.tags.map(&:name),
              likes_count: blog.likes_count,
              created_at: blog.created_at,
              comments: blog.comments.active.where(parent_comment_id: nil)
                            .map { |comment| serialize_comment(comment) }
          }

            status= :ok
        else
          response = { error: "Blog not found" }
          status = :not_found
        end
        render json: response, status: status

      rescue => e
        Rails.logger.error("Error fetching blog: #{e.message}")
        render json: { error: "Failed to fetch blog" }, status: :internal_server_error
      end

    end

    def my_blogs
      blogs = @current_user.blogs.active.includes(:tags).order(created_at: :desc)
      render json: blogs.map { |blog|
        {
          id: blog.id,
          title: blog.title,
          content: blog.content,
          author_name: blog.user.name,
          user_id: blog.user.id,
          tags: blog.tags.map(&:name),
          likes_count: blog.likes_count,
          comments_count: blog.comments_count,
          status: blog.status,
          scheduled_at: blog.scheduled_at,
          published_at: blog.published_at,
          created_at: blog.created_at
        }
      }, status: :ok
    end

    def following_blogs
      begin
        followed_user_ids = @current_user.following.pluck(:id)

        blogs = Blog.active
                    .where(user_id: followed_user_ids)
                    .includes(:user, :tags)
                    .order(created_at: :desc)

        render json: {
          blogs: blogs.map { |blog|
            {
              id: blog.id,
              title: blog.title,
              content: blog.content,
              author_name: blog.user.name,
              tags: blog.tags.map(&:name),
              likes_count: blog.likes_count,
              comments_count: blog.comments_count,
              created_at: blog.created_at
            }
          }
        }, status: :ok
      rescue => e
        render json: { error: e.message }, status: :unprocessable_entity
      end
    end


    def update
      begin
      blog = Blog.active.find_by(id: params[:id])

      if blog.nil?
        response = { error: "Blog not found" }
        status = :not_found

        elsif blog.user_id != current_user.id
          response = { error: "Not authorized to update this blog" }
          status = :unauthorized

        elsif blog.update(blog_params)
          response = { message: "Blog updation success", blog: blog }
          status = :ok
      else
        response = { errors: blog.errors.full_messages }
        status = :unprocessable_entity
      end

      render json: response, status: status

      rescue => e
        Rails.logger.error("Error updating blog: #{e.message}")
        render json: { error: "Failed to update blog" }, status: :internal_server_error
      end
    end

    def destroy
      begin
      blog = Blog.active.find_by(id: params[:id])

      if blog.nil?
        response = { error: "Blog not found" }
        status = :not_found
        elsif @current_user.admin? || blog.user_id == @current_user.id
        if blog.soft_delete(by_user: @current_user)
          response = { message: "Blog deleted successfully" }
          status = :ok
        else
          response = { errors: blog.errors.full_messages }
          status = :unprocessable_entity
        end
      else
        response = { error: "You are not authorized to delete this blog" }
        status = :unauthorized
      end

        render json: response, status: status

        rescue => e
        Rails.logger.error("Error deleting blog: #{e.message}")
        render json: { error: "Failed to delete blog" }, status: :internal_server_error
      end
    end

    def restore
      blog = Blog.deleted.find_by(id: params[:id])
      return render json: { error: "Blog not found or not deleted" }, status: :not_found unless blog

      if @current_user.admin?
        if blog.restore
          render json: { message: "Blog restored successfully" }, status: :ok
        else
          render json: { errors: blog.errors.full_messages }, status: :unprocessable_entity
        end
      else
        render json: { error: "You are not authorized to restore blogs" }, status: :unauthorized
      end
    end


    #show user preferred blogs on the top
    def prefered_blogs
      begin
      p_tags = UserTag.where(user_id: @current_user.id).pluck(:tag_id)

      # Blogs from last 24 hours (recent first, tag-preferred first)
      recent_blogs = Blog.active
                         .where("blogs.created_at >= ?", 1.day.ago)
                         .left_joins(:tags)
                         .select("DISTINCT ON (blogs.id) blogs.*")
                         .includes(:user, :tags)
                         .order("blogs.id, blogs.created_at DESC")

      # Within recent_blogs, reorder so that matching tags are prioritized
      recent_preferred = recent_blogs.select { |b| (b.tags.pluck(:id) & p_tags).any? }
      recent_others    = recent_blogs.reject { |b| (b.tags.pluck(:id) & p_tags).any? }

      # Older blogs
      p_blogs = Blog.active
                    .where("blogs.created_at < ?", 1.day.ago)
                    .joins(:tags)
                    .where(tags: { id: p_tags })
                    .select("DISTINCT ON (blogs.id) blogs.*")
                    .includes(:user, :tags)
                    .order("blogs.id, blogs.created_at DESC")

      other_blogs = Blog.active
                        .where("blogs.created_at < ?", 1.day.ago)
                        .where.not(id: p_blogs.map(&:id))
                        .includes(:user, :tags)
                        .order(created_at: :desc)

      # Final merge:
      blogs = recent_preferred + recent_others + p_blogs + other_blogs

      formatted_blogs = blogs.map do |blog|
        {
          id: blog.id,
          title: blog.title,
          content: blog.content,
          author_name: blog.user.name,
          tags: blog.tags.map(&:name),
          likes_count: blog.likes_count,
          comments_count: blog.comments_count,
          created_at: blog.created_at
        }
      end
      response = { blogs: formatted_blogs }
      status = :ok

      render json: response, status: status

    rescue => e
      Rails.logger.error("Error fetching preferred blogs: #{e.message}")
      render json: { error: "Failed to fetch preferred blogs" }, status: :internal_server_error
    end

    end


    def is_liked
      begin
        blog = Blog.active.find_by(id: params[:id])
        if blog.nil?
          response = { liked: false }
          status = :not_found
        else
          liked = Like.exists?(user_id: @current_user.id, blog_id: blog.id)
          response = { liked: liked }
          status = :ok
        end
        render json: response, status: status

    rescue => e
      Rails.logger.error("Error checking like status: #{e.message}")
      render json: { error: "Failed to check like status" }, status: :internal_server_error
    end
end



    private

    def find_blog
      begin
        @blog= Blog.find_by(id: params[:id])
        unless @blog
            render json: { error: "Blog not found"}, status: :not_found
        end
      rescue => e
        Rails.logger.error("Error finding blog: #{e.message}")
        render json: { error: "Failed to find blog" }, status: :internal_server_error
      end
    end
    
    def blog_params
        params.require(:blog).permit(:title, :content,:status, :scheduled_at, tag_ids: [])
    end

    def serialize_comment(comment)
      return nil if comment.deleted_at.present?
      {
        id: comment.id,
        content: comment.content,
        user_name: comment.user.name,
        user_id: comment.user.id,
        blog_id: comment.blog_id,
        created_at: comment.created_at,
        replies: comment.replies.active.map { |reply| serialize_comment(reply) }
      }
    end
end


