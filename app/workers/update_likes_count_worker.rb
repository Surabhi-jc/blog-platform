# app/workers/update_likes_count_worker.rb
class UpdateLikesCountWorker
  include Sidekiq::Worker
  sidekiq_options queue: :default, retry: 3


  def perform
    #Compute counts for blogs that have likes (one DB query)
    counts = Like.group(:blog_id).count

    #Update blogs that have likes (bulk updates)
    counts.each do |blog_id, ct|
      Blog.where(id: blog_id).update_all(likes_count: ct)
    end

    #For blogs that have zero likes, set likes_count = 0.
    if counts.any?
      Blog.where.not(id: counts.keys).update_all(likes_count: 0)
    else
      Blog.update_all(likes_count: 0)
    end
  end
end
