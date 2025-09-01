# app/workers/update_comment_count_worker.rb
class UpdateCommentsCountWorker
  include Sidekiq::Worker
  sidekiq_options queue: :default, retry: 3

  def perform
    # counts for blogs that have parent comments
    counts = Comment.where(parent_comment_id: nil, deleted_at: nil).group(:blog_id).count

    # Update blogs that have parent comments
    counts.each do |blog_id, ct|
      Blog.where(id: blog_id).update_all(comments_count: ct)
    end

    # comments_count = 0, for blogs that have zero parent comments
    if counts.any?
      Blog.where.not(id: counts.keys).update_all(comments_count: 0)
    else
      Blog.update_all(comments_count: 0)
    end
  end
end
