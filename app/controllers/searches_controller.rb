class SearchesController < ApplicationController
  def new
    @search = Search.new
  end

  def create
    @search = Search.new(params[:search])
    @tracks = @search.find_tracks
    render :new
  end

end
