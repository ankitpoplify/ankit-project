class CommentsController < ApplicationController
before_action :authenticate_author!, except: [:index, :show]
	before_action :signed_in_author,only:[:edit,:update,:destroy]
	def create
  @comment = Comment.new(comment_params)
  @comment.article_id = params[:article_id]
  @comment.author_name = current_author.name
  @comment.author_id = current_author.id
  @comment.save

  redirect_to article_path(@comment.article)
end
def signed_in_author
  	@article = Article.find(params[:article_id])
		@comment = Comment.find(params[:id])
  	if current_author.username != @comment.author_name
  		flash[:notice] = "Sorry Sir, You are not eligible"
  		redirect_to article_path(@article)
  	end
  end

def comment_params
  params.require(:comment).permit(:author_name, :body,:author_id)
end
end
