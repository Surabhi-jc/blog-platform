# app/workers/update_likes_count_worker.rb
class UpdateLikesCountWorker
  include Sidekiq::Worker
  sidekiq_options queue: :default

  def perform
    counts = Like.group(:blog_id).count

    update_changed_counts(counts)
    reset_zero_counts(counts)

    Rails.logger.info "[UpdateLikesCountWorker] Updated likes counts."
  end

  private

  def update_changed_counts(counts)
    counts.each do |blog_id, actual_count|
      blog = Blog.find_by(id: blog_id)
      next unless blog
      if blog.likes_count != actual_count
        blog.update(likes_count: actual_count)
      end
    end
  end

  def reset_zero_counts(counts)
    Blog.where.not(id: counts.keys)
        .where.not(likes_count: 0)
        .find_each do |blog|
      blog.update(likes_count: 0)
    end
  end
end
