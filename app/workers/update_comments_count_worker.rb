# app/workers/update_comments_count_worker.rb
class UpdateCommentsCountWorker
  include Sidekiq::Worker
  sidekiq_options queue: :default

  def perform
    counts = Comment
               .where(parent_comment_id: nil, deleted_at: nil)
               .group(:blog_id)
               .count

    update_changed_counts(counts)
    reset_zero_counts(counts)
  end

  private

  def update_changed_counts(counts)
    counts.each do |blog_id, actual_count|
      blog = Blog.find_by(id: blog_id)
      next unless blog
      if blog.comments_count != actual_count
        blog.update(comments_count: actual_count)
      end
    end
  end

  def reset_zero_counts(counts)
    Blog.where.not(id: counts.keys)
        .where.not(comments_count: 0)
        .find_each do |blog|
      blog.update(comments_count: 0)
    end
  end
end
