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
    # controllers/blogs_controller.rb
    # inside BlogsController
    def prefered_blogs
      limit   = (params[:limit] || 10).to_i
      after   = normalize_after(params[:after])
      user_id = @current_user.id

      cache_key     = "user:#{user_id}:preferred_blogs"
      tag_cache_key = "user:#{user_id}:tag_ids"

      user_tag_ids = fetch_user_tags(user_id, tag_cache_key)
      cached_rows  = fetch_cached_rows(cache_key)

      if after.nil?
        if cached_rows.present?
          Rails.logger.info("[prefered_blogs] served from cache top_rows=#{cached_rows.length}")
          blogs, next_cursor, has_more = format_blogs_response(cached_rows, limit)
          return render json: { blogs: blogs, next_cursor: next_cursor, has_more: has_more }, status: :ok
        end

        # cache miss for first page: compute top-100, cache it, and serve
        top_rows = PreferedBlogsFallback.fetch_top_rows(tag_ids: user_tag_ids)
        top_rows ||= []
        $redis.setex(cache_key, 300, top_rows.to_json) if top_rows.present?
        Rails.logger.info("[prefered_blogs] cache_miss computed_and_cached top_rows=#{top_rows.length}")
        blogs, next_cursor, has_more = format_blogs_response(top_rows, limit)
        return render json: { blogs: blogs, next_cursor: next_cursor, has_more: has_more }, status: :ok
      end

      # after present -> try to use cached slice (if cached_rows supplied) else DB fallback
      source_rows, used_cache = PreferedBlogsFallback.fetch(
        user_id: user_id,
        limit: limit,
        after: after,
        tag_ids: user_tag_ids,
        cached_rows: cached_rows
      )
      source_rows ||= []

      Rails.logger.info("[prefered_blogs] fetched rows_count=#{source_rows.length} used_cache=#{used_cache}")
      blogs, next_cursor, has_more = format_blogs_response(source_rows, limit)
      render json: { blogs: blogs, next_cursor: next_cursor, has_more: has_more }, status: :ok
    rescue => e
      Rails.logger.error("[prefered_blogs] #{e.class}: #{e.message}\n#{e.backtrace.take(10).join("\n")}")
      render json: { error: "Failed to fetch blogs" }, status: :internal_server_error
    end


    private

    def normalize_after(raw)
      return nil if raw.nil?
      s = raw.to_s.strip
      return nil if s.empty? || s.downcase == "null" || s.downcase == "undefined"
      s
    end

    def fetch_user_tags(user_id, tag_cache_key)
      if (j = $redis.get(tag_cache_key))
        JSON.parse(j)
      else
        ids = UserTag.where(user_id: user_id).pluck(:tag_id)
        $redis.setex(tag_cache_key, 300, ids.to_json)
        ids
      end
    end

    def fetch_cached_rows(cache_key)
      if (j = $redis.get(cache_key))
        Rails.logger.info("[prefered_blogs] cache hit: #{cache_key}, size=#{j.bytesize}")
        JSON.parse(j).map { |r| r.transform_keys(&:to_s) }
      else
        Rails.logger.info("[prefered_blogs] cache miss: #{cache_key}")
        nil
      end
    end

    def format_blogs_response(source_rows, limit)
      has_more = source_rows.length > limit
      page_rows = source_rows.first(limit)
      ids = page_rows.map { |r| r["id"] }

      records = ids.any? ? Blog.where(id: ids).includes(:user, :tags) : []
      map = records.index_by(&:id)
      priority_map = source_rows.each_with_object({}) { |r, h| h[r["id"]] = r["priority"].to_i }

      blogs = ids.map do |id|
        b = map[id]
        next unless b
        {
          id: b.id,
          title: b.title,
          content: b.content,
          author_name: b.user&.name,
          user_id: b.user.id,
          tags: b.tags.map(&:name),
          likes_count: b.likes_count,
          comments_count: b.comments_count,
          created_at: b.created_at,
          priority: priority_map[b.id] || 4
        }
      end.compact

      next_cursor = build_next_cursor(page_rows)

      [blogs, next_cursor, has_more]
    end

    def build_next_cursor(page_rows)
      return nil unless page_rows.any?

      last = page_rows.last
      t = last["created_at"]
      iso = t.respond_to?(:utc) ? t.utc.iso8601 : Time.parse(t.to_s).utc.iso8601
      "#{last['priority'].to_i}|#{iso}|#{last['id']}"
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


