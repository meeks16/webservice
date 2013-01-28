class TempsController < ApplicationController

	def sample 
	
    #@temps = Temp.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @temps.to_json }
    end
  end
end