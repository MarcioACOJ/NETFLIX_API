require 'csv'
class MoviesController < ApplicationController
  before_action :set_movie, only: %i[show update destroy]

  def index
    @movies = Movie.all
    @movies = @movies.where(country: params[:country]) if params[:country].present?
    @movies = @movies.where(genre: params[:genre]) if params[:genre].present?
    @movies = @movies.where(year: params[:year]) if params[:year].present?
    @movies = @movies.order_by(:year)

    render json: @movies.map { |m| map_movie(m) }
  end

  def show
    render json: map_movie(@movie)
  end

  def create
    @movie = Movie.new(movie_params)

    if @movie.save
      render json: map_movie(@movie), status: :created, location: @movie
    else
      render json: @movie.errors, status: :unprocessable_entity
    end
  end

  def update
    if @movie.update(movie_params)
      render json: map_movie(@movie)
    else
      render json: @movie.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @movie.destroy
  end

  def import
    movies = []
    File.open(params[:file], 'r') do |file|
      csv = CSV.read(file, headers: true)
      csv.each do |row|
        movie = Movie.find_or_initialize_by(title: row['title'])
        movie.external_id = Digest::SHA2.hexdigest(row['title'])
        movie.genre = row['type']
        movie.year = row['release_year']
        movie.country = row['country']
        movie.published_at = row['date_added']
        movie.description = row['description']
        movie.save
        movies << movie
      end
    end
    render json: movies.map { |m| map_movie(m) }
  end

  private

  def set_movie
    @movie = Movie.find_by(external_id: params[:id])
  end

  def movie_params
    params.require(:movie).permit(:title, :genre, :year, :country, :published_at, :description)
  end

  def map_movie(m)
    {
      id: m.external_id,
      title: m.title,
      genre: m.genre,
      year: m.year,
      country: m.country,
      published_at: m.published_at,
      description: m.description
    }
  end
end