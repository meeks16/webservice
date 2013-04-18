class TrendsController < ApplicationController
	
    	require "twitter"
    	require "json"
    	require "open-uri"
    	require "youtube_it"
    	require "rubygems"
    	
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
			panelArray = getPanelsForGooglePlus(maxPanels)
		elsif source == 't'
			panelArray = getPanelsForTwitter(maxPanels)
		else
			panelArray = (getPanelsForTwitter(maxPanels) + getPanelsForGooglePlus(maxPanels))
		end
		
		panelArray = panelArray.sort_by {|p| p.popularity}
		vidsx = 1
		
    	#panelArray = (getPanelsForGooglePlus() + getPanelsForTwitter())#.sort_by {|p| p.title}
    	
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
		tube = client.videos_by(:query => (searchFor.split /(?=[A-Z])/), :time => :today) 
 		sortedByViews = tube.videos.sort_by { |i| -i.view_count }		
		videoMaxCount = params[:v]
		
		if videoMaxCount == nil
			videoMaxCount = 10
		
		end
		
		logger.debug(tube.videos.count.to_s + '---videos count')
		logger.debug(videoMaxCount.to_s  + "video max class")
				
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
 	
 	
 	#Gets array of panels for twitter but without videos
 	
 	
 	def getPanelsForTwitter(panelMaxCount)
 		result = JSON.parse(open("https://api.twitter.com/1/trends/daily.json").read)
        logger.debug("------TwitterresultTrends:")
#     	topTen = result.first["trends"]
    	latestTime = result["trends"].keys.sort.last
    	
 		panelArray = Array.new 		
    	idx = 0
    	
#      	splitTopTen = topTen.split /(?=[A-Z])/

 		result["trends"][latestTime].each do |hashItem|
#  	 	splitTopTen.each do |hashItem|
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
 	
 	
 	def getPanelsForGooglePlus(panelMaxCount)
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
			panel.description = "GooglePlus"
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
 			#logger.debug("---: " + topic[0])
 			returnArr[idx] = arr[0] 			
 			idx += 1
		end
 		return returnArr
 	end
 
end

