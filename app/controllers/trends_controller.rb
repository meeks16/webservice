class TrendsController < ApplicationController
	
    	require "twitter"
    	require "json"
    	require "open-uri"
    	require "youtube_it"
    	require "rubygems"
    	
	class Panel
				attr_accessor :videos, :id, :boardId, :title, :description, :url, :thumbnailUrl
		
	end
	
	class Video
	attr_accessor :id, :panelId, :title, :description, :url, :thumbnailUrl, :publishDate, :numbersOfViews
	
	end

	def twitter  

		result = JSON.parse(open("https://api.twitter.com/1/trends/daily.json").read)
        client = YouTubeIt::Client.new(:dev_key => "AI39si788hPeW8wxxarNv9sPbq5uVClERQQArekZkdNRfIEd2sXH4dssEHgsudqqjmuH8RQFVhQALQ2tEYNNp8WcKWFeuQFHdg")
        
#         logger.debug("start -----------------")
       	
   		# tube = ""
    	latestTime = result["trends"].keys.first
    	
    	
    	
    	panelArray = Array.new
    	idx = 0
    	
 		result["trends"][latestTime].each do |hashItem|
 			searchFor = hashItem["name"]
					
			videoArray = Array.new
			vidx = 0
			
			logger.debug("--------------" + searchFor)
			tube = client.videos_by(:query => searchFor)
			
			logger.debug(tube.videos.count)
			if tube.videos.count == 0
				next
			end
			tube.videos.each do |video|
				
	 			vid = Video.new
	 			vid.id = video.object_id
	 			vid.panelId = "0"
	 			vid.title = video.title
	 			vid.description = video.description
	 			vid.url = video.player_url
	 			vid.thumbnailUrl = video.thumbnails.first.url
	 			vid.publishDate = video.published_at
	 			vid.numbersOfViews = video.view_count
	 			
	 			videoArray[vidx] = vid	
	 			vidx = vidx + 1
			end	
			
			
			panel = Panel.new
			panel.videos = videoArray
			logger.debug("panel video count: " + panel.videos.count.to_s) 			
			panel.id = 0
			panel.title = searchFor
			panel.description = "Twitter"
		
		
			panelArray[idx] =  panel
			idx = idx + 1
			
			if idx > 5
				break
			end
		end
	
   		topHash = {"Panels" => "", "Id" => 0, "Title" => "Trending", "Description" => "Trending"}
   		topHash["Panels"] = panelArray
   		

   		render :json => topHash
   		
 	end
 	
 	def googlePlus
 		resultTrends = JSON.parse(open("http://www.google.com/trends/hottrends/atom/hourly").read)
 	
 	end
 
end
# 

