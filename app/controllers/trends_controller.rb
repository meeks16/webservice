class TrendsController < ApplicationController
	
    	require "twitter"
    	require "json"
    	require "open-uri"
    	require "youtube_it"
    	require "rubygems"
    	require "oauth"
    	
	class Panel
		attr_accessor :videos, :id, :boardId, :title, :description, :url, :thumbnailUrl, :popularity
	end
	
	class Video
		attr_accessor :id, :panelId, :title, :description, :url, :thumbnailUrl, :publishDate, :numbersOfViews
	end

	def index  
		
		maxPanels = params[:p]
		source = params[:source]
		
		if maxPanels == nil
			maxPanels = 10
		else 
			maxPanels = maxPanels.to_i
		
		end

		if source == 'g'
			panelArray = getPanelsForGoogle(maxPanels)
		elsif source == 't'
			panelArray = getPanelsForTwitter(maxPanels)
		else
			panelArray = (getPanelsForTwitter(maxPanels) + getPanelsForGoogle(maxPanels))
		end
		
		panelArray = panelArray.sort_by {|p| p.popularity}
		vidsx = 1
		    	
   		panelArray.each do |panel|
 			searchFor = panel.title
 			logger.debug("--------------" + searchFor)
 			logger.debug (params[:source])
			panel.videos = getVideoArrayForTopic(searchFor)
		
						
			if panel.videos.count > 0 then
				vidsx = vidsx + 1
				
 			end
 			
 			logger.debug (vidsx.class)
 			logger.debug (maxPanels.class)
 			
 			if vidsx > maxPanels
 				break
 			end
		end
		
		

 		panelArray.delete_if { |p| p.videos.count == 0 }
		
   		topHash = {"Panels" => "", "Id" => 0, "Title" => "Trending", "Description" => "Trending"}
   		topHash["Panels"] = panelArray
   		
   		render :json => topHash
 	end
 	
 	def getVideoArrayForTopic(searchFor)
 		client = YouTubeIt::Client.new(:dev_key => "AI39si788hPeW8wxxarNv9sPbq5uVClERQQArekZkdNRfIEd2sXH4dssEHgsudqqjmuH8RQFVhQALQ2tEYNNp8WcKWFeuQFHdg")
 		
 		videoArray = Array.new
		vidx = 0
		vidsx =0
		tube = client.videos_by(:query => (searchFor.to_s.split /(?=[A-Z])/))
 		logger.debug((searchFor.split /(?= [A-Z])/).to_s + "-----split words" )
 		sortedByViews = tube.videos.sort_by { |i| -i.view_count }		
		videoMaxCount = params[:v]
		
		if videoMaxCount == nil
			videoMaxCount = 10
		
		end
		
				
		sortedByViews.each do |video|
		
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

 			if (vidx > videoMaxCount.to_i - 1)
				break
			end
		end	
		return videoArray
 	end 	
 	
 	def getPanelsForTwitter(panelMaxCount)
 	
		client = Twitter::Client.new(
			:consumer_key => 'A0UNh1W5VFG5JoH3UATjA',
	 		:consumer_secret => 'TeegpJ9iomDCN7l4jtCihTif9i0RQKGIGnJLNihZZE',
	 		:oauth_token => '1152202844-TQsnzb2omGTSVajOM5D719KnwX4d9zklJSzaFkq',
	 		:oauth_token_secret => 'ZHbTPAuArstU20Rbr4quy1vRZihiNnvgI1EWK98D6c'
	 	)
	 	
	 	usa = client.trends(23424977)
	 	world = client.trends(1)
	 	
 		trendLocation = params[:woeid]
 		
 		if trendLocation == nil
 			result = world
 		end
 		
 		if trendLocation.to_i == 23424977
 			result = usa
 		end
 		
        logger.debug("------TwitterresultTrends:")

 		panelArray = Array.new 		
    	idx = 0
  	 	result.each do |hashItem|
			panel = Panel.new
			panel.videos = []		
			panel.id = 0
			panel.title = hashItem["name"]
			panel.description = "Twitter"
			panel.popularity = idx + 1
			panelArray[idx] =  panel
			idx = idx + 1
			
			if (idx > ((panelMaxCount.to_i) -1))
				break
			end
			
		end
		
		return panelArray
 	end
 	
 	
 	def getPanelsForGoogle(panelMaxCount)
 	
 		
 		resultTrends = JSON.parse(open("https://ajax.googleapis.com/ajax/services/feed/load?v=1.0&q=http%3A%2F%2Fwww.google.com%2Ftrends%2Fhottrends%2Fatom%2Fhourly").read)
 		
 		logger.debug("------resultTrends:")
 		topicsHtml =  resultTrends["responseData"]["feed"]["entries"][0]["content"]
 		panelArray = Array.new
 		idx = 0
 		topicsArr = convertGoogleTopicsHtmlToArray(topicsHtml)
 		topicsArr.each do |topic|
 		
 			panel = Panel.new
			panel.videos = []		
			panel.id = 0
			panel.title = topic
			panel.description = "Google"
			panel.popularity = idx + 1
			panelArray[idx] =  panel
			idx = idx + 1
			if (idx > ((panelMaxCount.to_i) -1))
				break
			end
			
 			logger.debug("---: " + topic)
		end
		
 		return panelArray	
 		
 	end
 	
 	def convertGoogleTopicsHtmlToArray(topicsHtml)
 		topicsArr = topicsHtml.scan(/<a.+?>(.+?)<\/a>/)
 		returnArr = []
 		idx = 0
 		topicsArr.each do |arr|
 			returnArr[idx] = arr[0] 			
 			idx += 1
		end
 		return returnArr
 	end
 
end

