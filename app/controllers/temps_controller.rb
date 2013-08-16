class TempsController < ApplicationController
	require 'twitter'
	require 'oAuth'
	
	def sample
		client = Twitter::Client.new(
			:consumer_key => 'A0UNh1W5VFG5JoH3UATjA',
	 		:consumer_secret => 'TeegpJ9iomDCN7l4jtCihTif9i0RQKGIGnJLNihZZE',
	 		:oauth_token => '1152202844-TQsnzb2omGTSVajOM5D719KnwX4d9zklJSzaFkq',
	 		:oauth_token_secret => 'ZHbTPAuArstU20Rbr4quy1vRZihiNnvgI1EWK98D6c'
	 	)
		
		string = client.trends(23424977)
#  		result = JSON.parse(open(https://api.twitter.com/1.1/trends/place.json?id=1).read)
# 		result
		string
# 		Twitter.configure do |config|
# 	 		config.consumer_key = 'A0UNh1W5VFG5JoH3UATjA'
# 	 		config.consumer_secret = 'TeegpJ9iomDCN7l4jtCihTif9i0RQKGIGnJLNihZZE'
# 	 		config.oauth_token = '1152202844-TQsnzb2omGTSVajOM5D719KnwX4d9zklJSzaFkq'
# 	 		config.oauth_token_secret = 'ZHbTPAuArstU20Rbr4quy1vRZihiNnvgI1EWK98D6c'
# 	 	end
	 	
# 	 	Twitter.trends(23424977)
	end

end
