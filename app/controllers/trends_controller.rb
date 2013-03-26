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

	def index  
    	panelArray = (getPanelsForGooglePlus() + getPanelsForTwitter()).sort_by {|p| p.title}
 		panelArray.each do |panel|
 			searchFor = panel.title
			logger.debug("--------------" + searchFor)
			
			panel.videos = getVideoArrayForTopic(searchFor)
			
			if (panel.videos.count == 0)
				panelArray.delete(panel)
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
		tube = client.videos_by(:query => searchFor, :time => :today) 
 		sortedByDate = tube.videos.sort_by { |i| -i.view_count }
# 		client.videos_by(:fields => {:published  => ((Date.today)})
# 		videoArray.sort { |x, y| x.last[:date] <=> y.last[:date] }
		logger.debug(tube.videos.count)
		sortedByDate.each do |video|

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
 			if (vidx > 15)
				break
			end

		end	
		
		return videoArray
 	end
 	
 	
 	#Gets array of panels for twitter but without videos
 	def getPanelsForTwitter()
 		result = JSON.parse(open("https://api.twitter.com/1/trends/daily.json").read)
        
    	latestTime = result["trends"].keys.first
 		panelArray = Array.new
    	idx = 0
    	
 		result["trends"][latestTime].each do |hashItem|
			panel = Panel.new
			panel.videos = []		
			panel.id = 0
			panel.title = hashItem["name"]
			panel.description = "Twitter"
		
			panelArray[idx] =  panel
			idx = idx + 1
			if (idx > 10)
				break
			end
		end
		return panelArray
 	end
 	
 	
 	def getPanelsForGooglePlus
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
		
			panelArray[idx] =  panel
			idx = idx + 1
			if (idx > 10)
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
# 

