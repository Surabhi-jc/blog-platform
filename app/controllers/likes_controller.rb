class LikesController < ApplicationController
    before_action :authorize_request

    def create

        response_data = {}
        status_code = nil

        blog= Blog.find_by(id: params[:blog_id])

        if blog.nil?
            response_data= { error: "Blog not found"}
            status_code= :not_found

        else

            #entry into Like table
        like= Like.new(user_id: current_user.id, blog_id: blog.id)

        if like.save
            #create entry in UserTag table for each tag

            blog.tags.each do |tag|
                UserTag.find_or_create_by(user_id: current_user.id, tag_id: tag.id)
            end

            response_data= {message: "Blog liked and tag preference updated"}
            status_code = :created
          else
            response_data = { errors: like.errors.full_messages }
            status_code = :unprocessable_entity
          end
        end
        render json: response_data, status: status_code
    end





    def destroy
      begin
        response_data = {}
        status_code = nil

        blog= Blog.find_by(id: params[:blog_id])

        if blog.nil?
            response_data = { error: "Blog not found" }
            status_code = :not_found
        else
          like= Like.find_by(user_id: current_user.id, blog_id: blog.id)
         if like.nil?
            response_data = { error: "Like not found" }
            status_code = :not_found
         else
            like.destroy
            response_data = { message: "Blog unliked " }
            status_code = :ok
        end
    end

        render json: response_data, status: status_code
      rescue => e
        Rails.logger.error("Error unliking blog: #{e.message}\n#{e.backtrace.join("\n")}")
        render json: { error: "Failed to unlike blog" }, status: :internal_server_error
      end
    end

end
