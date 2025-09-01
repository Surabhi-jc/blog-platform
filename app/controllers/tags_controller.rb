class TagsController < ApplicationController
  def show_tags
    begin
      tags = Tag.all
      render json: { tags: tags }, status: :ok
    rescue => e
      Rails.logger.error("Error fetching tags: #{e.message}")
      render json: { error: "Failed to fetch tags" }, status: :internal_server_error
    end
 end
end
