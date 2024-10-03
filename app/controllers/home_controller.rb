class HomeController < ApplicationController
  def index
    @info_view = params[:info_view]
    @documents = Document.all

    respond_to do |format|
      format.html { render :index }
      format.turbo_stream do
        if @info_view == "fast"
          render turbo_stream: turbo_stream.replace("info_tag", partial: "home/info_tags/fast")
        elsif @info_view == "versatile"
          render turbo_stream: turbo_stream.replace("info_tag", partial: "home/info_tags/versatile")
        elsif @info_view == "easy"
          render turbo_stream: turbo_stream.replace("info_tag", partial: "home/info_tags/easy")
        else
          render turbo_stream: turbo_stream.replace("info_tag", partial: "home/info_tags/empty")
        end
      end
    end
  end
end
