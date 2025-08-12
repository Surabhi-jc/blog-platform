class TagsController < ApplicationController
  def show_tags
   tags = Tag.all
   render json: { tags: tags }, status: :ok
 end
end
