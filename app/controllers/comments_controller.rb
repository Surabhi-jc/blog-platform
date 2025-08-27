class CommentsController < ApplicationController
  protect_from_forgery with: :null_session  # disable CSRF for API
  before_action :authorize_request
  before_action :set_blog

  def create
    @comment = @blog.comments.build(comment_params) # build saves in memory not in db
    @comment.user = @current_user

    if @comment.save
      render json: {
        id: @comment.id,
        content: @comment.content,
        user_name: @comment.user.name,
        parent_comment_id: @comment.parent_comment_id,
        created_at: @comment.created_at
      }, status: :created
    else
      render json: { errors: @comment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    comment = @blog.comments.find_by(id: params[:comment_id])
    return render json: { error: "Comment not found" }, status: :not_found unless comment

    if comment.user_id != @current_user.id
      render json: { error: "You are not authorized to delete this comment" }, status: :unauthorized
    elsif comment.soft_delete(by_user: @current_user)
      render json: { message: "Comment deleted successfully" }, status: :ok
    else
      render json: { errors: comment.errors.full_messages }, status: :unprocessable_entity
    end
  end


  private

  def set_blog
    @blog = Blog.find_by(id: params[:id])
    unless @blog
      render json: { error: "Blog with id=#{params[:id]} not found" }, status: :not_found
    end
  end

  def comment_params
    params.require(:comment).permit(:content, :parent_comment_id)
  end

end
