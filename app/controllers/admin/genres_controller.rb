class Admin::GenresController < ApplicationController
  before_action :authenticate_admin!
  
  def index
    @genre = Genre.new
    @genres = Genre.all
  end

  def create
    @genre = Genre.new(genre_params)

    if @genre.save
      flash[:notice] = "ジャンルの登録に成功しました。"
      redirect_to admin_genres_path
    else
      flash.now[:notice] = "ジャンルの登録に失敗しました。"
      @genres = Genre.all
      render :index
    end

  end

  def edit
    @genre = Genre.find(params[:id])
  end

  def update
    @genre=Genre.find(params[:id])

    if @genre.update(genre_params)
      flash[:notice] = "ジャンルの編集に成功しました。"
      redirect_to admin_genres_path
    else
      flash.now[:notice] = "ジャンルの編集に失敗しました。"
      @genre = Genre.find(params[:id])
      render :edit
    end

  end

  private

  def genre_params
    params.require(:genre).permit(:name)
  end

end
