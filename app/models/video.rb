class Video < ActiveRecord::Base
  attr_accessible :publishdate, :thumbnailurl, :title, :url, :view
end
