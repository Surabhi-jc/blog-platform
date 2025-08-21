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
        created_at: @comment.created_at
      }, status: :created
    else
      render json: { errors: @comment.errors.full_messages }, status: :unprocessable_entity
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
