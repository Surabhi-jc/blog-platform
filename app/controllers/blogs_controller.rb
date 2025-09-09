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
        limit = (params[:limit] || 10).to_i
        after = params[:after] # expected "ISO_TIMESTAMP|ID" e.g. "2025-09-03T12:31:40.310Z|185478"

        scope = Blog.active.includes(:user, :tags).order(created_at: :desc, id: :desc)

        if after.present?
          time_str, id_str = after.split("|")
          after_time = Time.parse(time_str) rescue nil
          after_id = id_str.to_i

          if after_time
            scope = scope.where(
              "blogs.created_at < ? OR (blogs.created_at = ? AND blogs.id < ?)",
              after_time, after_time, after_id
            )
          end
        end

        batch = scope.limit(limit + 1).to_a
        has_more = batch.size > limit
        page = batch.first(limit)

        formatted = page.map { |b|
          {
            id: b.id,
            title: b.title,
            content: b.content,
            author_name: b.user.name,
            tags: b.tags.map(&:name),
            likes_count: b.likes_count,
            comments_count: b.comments_count,
            created_at: b.created_at
          }
        }

        next_cursor = nil
        if page.any?
          last = page.last
          next_cursor = "#{last.created_at.iso8601}|#{last.id}"
        end

        render json: { blogs: formatted, next_cursor: next_cursor, has_more: has_more }, status: :ok
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
          created_at: blog.created_at
        }
      }, status: :ok
    end

    # app/controllers/blogs_controller.rb
    def following_blogs
      begin
        limit = (params[:limit] || 10).to_i
        limit = 1 if limit < 1
        after = params[:after] # expected format "2025-09-05T12:34:56Z|185478" or nil

        followed_user_ids = @current_user.following.pluck(:id)
        # If user follows nobody, return empty soon
        if followed_user_ids.empty?
          return render json: { blogs: [], next_cursor: nil, has_more: false }, status: :ok
        end

        scope = Blog.active
                    .where(user_id: followed_user_ids)
                    .includes(:user, :tags)
                    .order(created_at: :desc, id: :desc)

        # Apply cursor if provided — parse "time|id"
        if after.present?
          begin
            time_str, id_str = after.split("|", 2)
            cursor_time = Time.iso8601(time_str) rescue nil
            cursor_id = id_str.to_i

            if cursor_time
              # Fetch rows strictly older than (cursor_time, cursor_id) in (created_at DESC, id DESC) ordering.
              scope = scope.where(
                "blogs.created_at < ? OR (blogs.created_at = ? AND blogs.id < ?)",
                cursor_time, cursor_time, cursor_id
              )
            else
              Rails.logger.warn("following_blogs: invalid cursor #{after.inspect} - ignoring")
            end
          rescue => parse_e
            Rails.logger.warn("following_blogs: failed to parse cursor #{after.inspect} - #{parse_e.message}")
          end
        end

        rows = scope.limit(limit + 1).to_a
        has_more = rows.length > limit
        page = rows.first(limit)

        formatted = page.map do |b|
          {
            id: b.id,
            title: b.title,
            content: b.content,
            author_name: b.user&.name,
            tags: b.tags.map(&:name),
            likes_count: b.likes_count,
            comments_count: b.comments_count,
            created_at: b.created_at
          }
        end

        next_cursor = if page.any?
                        last = page.last
                        "#{last.created_at.utc.iso8601}|#{last.id}"
                      end

        render json: { blogs: formatted, next_cursor: next_cursor, has_more: has_more }, status: :ok
      rescue => e
        Rails.logger.error("Error in following_blogs: #{e.message}\n#{e.backtrace.join("\n")}")
        render json: { error: "Failed to fetch following blogs" }, status: :internal_server_error
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
    # app/controllers/blogs_controller.rb
    # app/controllers/blogs_controller.rb
    def prefered_blogs
      limit = (params[:limit] || 10).to_i
      after = params[:after] # "priority|ISO_TIMESTAMP|id" or nil
      user_id = @current_user.id
      one_day_ago_iso = 1.day.ago.utc.iso8601

      # CASE SQL using EXISTS (join to user_tags inside the EXISTS)
      case_sql = <<~SQL.squish
    CASE
      WHEN blogs.created_at >= '#{one_day_ago_iso}'::timestamptz
           AND EXISTS (
             SELECT 1 FROM blog_tags bt
             JOIN user_tags ut ON ut.tag_id = bt.tag_id
             WHERE bt.blog_id = blogs.id AND ut.user_id = #{user_id}
           ) THEN 1
      WHEN blogs.created_at >= '#{one_day_ago_iso}'::timestamptz THEN 2
      WHEN EXISTS (
             SELECT 1 FROM blog_tags bt
             JOIN user_tags ut ON ut.tag_id = bt.tag_id
             WHERE bt.blog_id = blogs.id AND ut.user_id = #{user_id}
           ) THEN 3
      ELSE 4
    END
  SQL

      # Build a derived table that computes priority ONCE per blog
      subquery_sql = Blog.active
                         .select("blogs.*, (#{case_sql}) AS priority")
                         .to_sql

      # Treat that derived SQL as a table "prioritized"
      prioritized = Blog.from("(#{subquery_sql}) AS prioritized")

      # Apply cursor filtering on the computed priority column (no re-eval)
      if after.present?
        pr_str, created_at_str, id_str = after.split("|", 3)
        cursor_priority = pr_str.to_i
        cursor_time = Time.iso8601(created_at_str) rescue nil
        cursor_id = id_str.to_i

        if cursor_time
          prioritized = prioritized.where(<<-SQL, cursor_priority: cursor_priority, cursor_time: cursor_time, cursor_id: cursor_id)
        (priority > :cursor_priority)
        OR (
          priority = :cursor_priority
          AND (created_at < :cursor_time OR (created_at = :cursor_time AND id < :cursor_id))
        )
      SQL
        end
      end

      rows = prioritized
               .order("priority ASC, created_at DESC, id DESC")
               .limit(limit + 1)
               .includes(:user)  # load user along with rows to avoid N+1 for author_name
               .to_a

      has_more = rows.length > limit
      page = rows.first(limit)

      # Preload tags only for the returned page (no join explosion)
      ActiveRecord::Associations::Preloader.new.preload(page, :tags)

      formatted = page.map do |b|
        {
          id: b.id,
          title: b.title,
          content: b.content,
          author_name: b.user&.name,
          tags: b.tags.map(&:name),
          likes_count: b.likes_count,
          comments_count: b.comments_count,
          created_at: b.created_at,
          priority: (b.respond_to?(:priority) ? b.priority.to_i : nil)
        }
      end

      next_cursor = if page.any?
                      last = page.last
                      "#{last.priority.to_i}|#{last.created_at.utc.iso8601}|#{last.id}"
                    end

      render json: { blogs: formatted, next_cursor: next_cursor, has_more: has_more }, status: :ok
    end


    def my_deleted_blogs
      blogs = @current_user.blogs
                           .where.not(deleted_at: nil)
                           .includes(:user, :deleted_by, :tags)

      formatted = blogs.map do |b|
        {
          id: b.id,
          title: b.title,
          content: b.content,
          author_name: b.user&.name,  # add this
          tags: b.tags.map(&:name),
          likes_count: b.likes_count,
          comments_count: b.comments_count,
          deleted_at: b.deleted_at,
          deleted_by: b.deleted_by&.as_json(only: [:id, :name, :is_admin])
        }
      end

      render json: formatted, status: :ok
    rescue => e
      render json: { error: "Failed to fetch deleted blogs", details: e.message }, status: :internal_server_error
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


