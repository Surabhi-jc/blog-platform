class CommentsController < ApplicationController
  protect_from_forgery with: :null_session  # disable CSRF for API
  before_action :authorize_request
  before_action :set_blog

  def create
    begin
    @comment = @blog.comments.build(comment_params) # build saves in memory not in db
    @comment.user = @current_user

    if @comment.save
      response= {
        id: @comment.id,
        content: @comment.content,
        user_name: @comment.user.name,
        parent_comment_id: @comment.parent_comment_id,
        created_at: @comment.created_at
      }
      status= :created
    else
      response = { errors: @comment.errors.full_messages }
      status = :unprocessable_entity
    end

    render json: response, status: status

    rescue => e
      Rails.logger.error("Error finding blog: #{e.message}")
      render json: { error: "Failed to create comment" }, status: :internal_server_error
    end
  end

  def destroy
    begin
     comment = @blog.comments.find_by(id: params[:comment_id])

     if comment.nil?
       response = { error: "Comment not found" }
       status   = :not_found

       elsif comment.user_id != @current_user.id && !@current_user.is_admin
         response = { error: "You are not authorized to delete this comment" }
         status   = :unauthorized

       elsif comment.soft_delete(by_user: @current_user)
         response = { message: "Comment deleted successfully" }
         status   = :ok
     else
       response = { errors: comment.errors.full_messages }
       status   = :unprocessable_entity
     end
     render json: response, status: status

    rescue => e
      Rails.logger.error("Error finding blog: #{e.message}")
      render json: { error: "Failed to delete comment" }, status: :internal_server_error
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
