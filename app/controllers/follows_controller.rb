class FollowsController < ApplicationController
  before_action :authorize_request
  before_action :set_user

  # POST /user/:id/follow
  def follow
    begin
      response = {}

      if @current_user.id == @user.id
        response[:error] = "You cannot follow yourself"
        status = :unprocessable_entity
      else
        follow = @current_user.active_follows.find_or_initialize_by(followed: @user) #prevents duplicate follows

        if follow.persisted? # already exists
          response[:message] = "Already following this user"
          status = :ok
        elsif follow.save
          response[:message] = "Followed successfully"
          status = :created
        else
          response[:error] = follow.errors.full_messages
          status = :unprocessable_entity
        end
      end

      render json: response, status: status
    rescue => e
      render json: { error: e.message }, status: :internal_server_error
    end
  end

  # DELETE /user/:id/unfollow
  def unfollow
    begin
      response = {}
      follow = @current_user.active_follows.find_by(followed: @user)

      if follow
        follow.destroy
        response[:message] = "Unfollowed successfully"
        status = :ok
      else
        response[:error] = "Not following this user"
        status = :not_found
      end

      render json: response, status: status
    rescue => e
      render json: { error: e.message }, status: :internal_server_error
    end
  end

  # GET /user/:id/followers
  def followers
    begin
      followers = @user.followers.select(:id, :name, :email)
      render json: { followers: followers }, status: :ok
    rescue => e
      render json: { error: e.message }, status: :internal_server_error
    end
  end

  # GET /user/:id/following
  def following
    begin
      following = @user.following.select(:id, :name, :email)
      render json: { following: following }, status: :ok
    rescue => e
      render json: { error: e.message }, status: :internal_server_error
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end
