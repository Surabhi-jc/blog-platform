class LikesController < ApplicationController
    before_action :authorize_request

    def create
        blog= Blog.find_by(id: params[:blog_id])
        return render json: {error: "Blog not found"}, status: :not_found unless blog

        #entry into Like table
        like= Like.new(user_id: current_user.id, blog_id: blog.id)

        if like.save
            #create entry in UserTag table for each tag

            blog.tags.each do |tag|
                UserTag.find_or_create_by(user_id: current_user.id, tag_id: tag.id)
            end

            render json: {message: "Blog liked and tag preference updated"}, status: :created
        else
            render json: {errors: like.errors.full_messages}, status: :unprocessable_entity
        end
    end

    def destroy
        blog= Blog.find_by(id: params[:blog_id])
        return render json: {error: "Blog not found"}, status: :not_found unless blog

        like= Like.find_by(user_id: current_user.id, blog_id: blog.id)
        return render json: {error: "Like not found"}, status: :not_found unless like

        like.destroy
        render json: { message: "Blog unliked and tag preference updated" }, status: :ok
    end
    
end
