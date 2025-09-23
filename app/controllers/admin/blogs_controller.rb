# app/controllers/admin/blogs_controller.rb
class Admin::BlogsController < ApplicationController
  before_action :authorize_request
  before_action :require_admin

  # GET /admin/blogs/active
  def active
    blogs=Blog.active.includes(:user, :tags).order(created_at: :desc)
    render json: blogs.map {|blog|
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

  # GET /admin/blogs/deleted
  def deleted
    blogs = Blog.deleted.includes(:user, :tags, :deleted_by).order(deleted_at: :desc)

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
        created_at: blog.created_at,
        deleted_at: blog.deleted_at,
        deleted_by: blog.deleted_by ? { id: blog.deleted_by.id, name: blog.deleted_by.name } : nil
      }
    }, status: :ok
  end

  private

  def require_admin
    unless @current_user.is_admin?
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end
end
