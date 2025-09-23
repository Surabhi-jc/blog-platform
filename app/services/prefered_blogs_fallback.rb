# app/services/prefered_blogs_fallback.rb
class PreferedBlogsFallback

  def self.fetch(user_id:, limit:, after:, cached_rows:, tag_ids:)
    service = new(user_id, limit.to_i, after, cached_rows, tag_ids)
    service.fetch
  end

  def self.fetch_top_rows(tag_ids:)
    conn = ActiveRecord::Base.connection
    tags_list = tag_ids.any? ? tag_ids.join(",") : "NULL"
    one_day_ago = 1.day.ago.utc.iso8601

    inner = <<~SQL
      SELECT b.id, b.created_at,
        (CASE
           WHEN b.created_at >= #{conn.quote(one_day_ago)}::timestamptz
                AND EXISTS (SELECT 1 FROM blog_tags bt WHERE bt.blog_id = b.id AND bt.tag_id IN (#{tags_list}))
             THEN 1
           WHEN b.created_at >= #{conn.quote(one_day_ago)}::timestamptz THEN 2
           WHEN EXISTS (SELECT 1 FROM blog_tags bt WHERE bt.blog_id = b.id AND bt.tag_id IN (#{tags_list})) THEN 3
           ELSE 4
         END)::int AS priority
      FROM blogs b
      WHERE b.deleted_at IS NULL
    SQL

    sql = <<~SQL
      SELECT p.id, p.created_at, p.priority
      FROM (#{inner}) AS p
      ORDER BY p.priority ASC, p.created_at DESC, p.id DESC
      LIMIT 100
    SQL

    conn.exec_query(sql).to_a
  end

  def initialize(user_id, limit, after, cached_rows, tag_ids)
    @user_id = user_id
    @limit = limit
    @after = after
    # normalize cached rows to array of hashes with string keys
    @cached = Array(cached_rows).map { |r| r.is_a?(Hash) ? r.transform_keys(&:to_s) : r }
    @tag_ids = tag_ids || []
    @conn = ActiveRecord::Base.connection
  end

  # returns [source_rows_array, used_cache_boolean]
  def fetch

    if @cached.any? && @after.present?
      Rails.logger.info("[PreferedBlogsFallback] try cached slice (cached_count=#{@cached.length})")
      pr, created_at_str, id_str = @after.split("|", 3)
      cursor_priority = pr.to_i
      cursor_time = (Time.iso8601(created_at_str) rescue nil)
      cursor_id = id_str.to_i

      if cursor_time
        idx = find_cursor_index(@cached, cursor_id, cursor_priority, cursor_time)
        if idx
          remaining = @cached[(idx + 1)..-1] || []
          if remaining.length > @limit
            Rails.logger.info("[PreferedBlogsFallback] cursor inside cached slice idx=#{idx} remaining=#{remaining.length}")
            return [remaining.dup, true]
          else
            Rails.logger.info("[PreferedBlogsFallback] cached remaining insufficient (#{remaining.length}) -> DB fallback")
          end
        else
          Rails.logger.info("[PreferedBlogsFallback] cursor not found in cache -> DB fallback")
        end
      end
    end

    # DB fallback
    rows = fetch_from_db(@tag_ids, @after, @limit)
    [rows, false]
  end

  private

  def find_cursor_index(rows, cursor_id, cursor_priority, cursor_time)
    rows.find_index do |r|
      next false unless r.is_a?(Hash) && r["id"] && r["created_at"]
      r_time = Time.parse(r["created_at"].to_s).utc
      r["id"].to_i == cursor_id && r["priority"].to_i == cursor_priority && r_time.to_i == cursor_time.utc.to_i
    end
  end

  def fetch_from_db(tag_ids, after, limit)
    tags_list = tag_ids.any? ? tag_ids.join(",") : "NULL"
    one_day_ago = 1.day.ago.utc.iso8601

    inner = <<~SQL
      SELECT b.id, b.created_at,
        (CASE
           WHEN b.created_at >= #{@conn.quote(one_day_ago)}::timestamptz
                AND EXISTS (SELECT 1 FROM blog_tags bt WHERE bt.blog_id = b.id AND bt.tag_id IN (#{tags_list}))
             THEN 1
           WHEN b.created_at >= #{@conn.quote(one_day_ago)}::timestamptz THEN 2
           WHEN EXISTS (SELECT 1 FROM blog_tags bt WHERE bt.blog_id = b.id AND bt.tag_id IN (#{tags_list})) THEN 3
           ELSE 4
         END)::int AS priority
      FROM blogs b
      WHERE b.deleted_at IS NULL
    SQL

    where_clause = ""
    if after.present?
      pr, created_at_str, id_str = after.split("|", 3)
      cursor_priority = pr.to_i
      cursor_time = (Time.iso8601(created_at_str) rescue nil)
      cursor_id = id_str.to_i
      if cursor_time
        q_time = @conn.quote(cursor_time.utc.iso8601) + "::timestamptz"
        where_clause = <<~SQL.squish
          WHERE (
            (priority > #{cursor_priority})
            OR (
              priority = #{cursor_priority}
              AND (created_at < #{q_time} OR (created_at = #{q_time} AND id < #{cursor_id}))
            )
          )
        SQL
      end
    end

    final_sql = <<~SQL
      SELECT p.id, p.created_at, p.priority
      FROM (#{inner}) AS p
      #{where_clause}
      ORDER BY p.priority ASC, p.created_at DESC, p.id DESC
      LIMIT #{limit + 1}
    SQL

    @conn.exec_query(final_sql).to_a
  end
end
