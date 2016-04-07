class ArticlesController < ApplicationController
  before_action :set_article, only: [:show, :edit, :update, :destroy]
 before_action :authenticate_author!, except: [:index, :show, :profile]
  before_action :signed_in_author,only:[:edit,:update,:destroy]
  # GET /articles
  # GET /articles.json
  def index
   
    @articles = Article.all
    

    if params[:search]
    @articles = Article.search(params[:search]).order("created_at DESC")
  else
    @articles = Article.all
  end
  end

  # GET /articles/1
  # GET /articles/1.json
  def show
    @articles = Article.all
    @comment = Comment.new
    @comment.article_id = @article.id
  end

  # GET /articles/new
  def new
    @article = Article.new

  end

  # GET /articles/1/edit
  def edit
  end

  # POST /articles
  # POST /articles.json
  def create
    @article = Article.new(article_params)
    @article.author_id = current_author.id
    respond_to do |format|
      if @article.save(article_params)
        format.html{ render :crop}
        #format.html { redirect_to @article, notice: 'Article was successfully created.' }
        #format.json { render :show, status: :created, location: @article }
      else
        format.html { render :new }
        format.json { render json: @article.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /articles/1
  # PATCH/PUT /articles/1.json
  def update
    respond_to do |format|
      if @article.update(article_params)
        format.html{ render :crop}
        #format.html { redirect_to @article, notice: 'Article was successfully updated.' }
        #format.json { render :show, status: :ok, location: @article }
      else
        format.html { render :edit }
        format.json { render json: @article.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /articles/1
  # DELETE /articles/1.json
  def destroy
    @article.destroy
    respond_to do |format|
      format.html { redirect_to articles_url, notice: 'Article was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
def profile
 
  @author=Author.find(params[:id])
  end
  def signed_in_author
    @article = Article.find(params[:id])
    if current_author.id != @article.author_id
      flash[:notice] = "Sorry Sir, You are not eligible"
      redirect_to article_path(@article)
    end
  end
  def crop

    @article=Article.find(params[:id])
       
       @article.photo_crop_x=params[:article][:photo_crop_x]
        @article.photo_crop_y=params[:article][:photo_crop_y]
       @article.photo_crop_w=params[:article][:photo_crop_w]
        @article.photo_crop_h=params[:article][:photo_crop_h]
             @article.photo_aspect=params[:article][:photo_aspect]
        
    
        @article.save
        redirect_to article_path(@article), notice: 'Image was successfully cropped.' 
     
  end
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_article
      @article = Article.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def article_params
      params.fetch(:article, {}).permit(:title, :body,:tag_list,:photo,:author_id,:photo_crop_x,:photo_crop_y,:photo_crop_w,:photo_crop_h,:photo_aspect)
    end
end
