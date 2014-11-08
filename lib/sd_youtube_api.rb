# https://developers.google.com/youtube/v3/code_samples/ruby#search_by_keyword

class SdYoutubeApi
  attr_reader :videos, :channels, :playlists

    # Set DEVELOPER_KEY to the "API key" value from the "Access" tab of the
    # Google Developers Console <https://cloud.google.com/console>
    # Please ensure that you have enabled the YouTube Data API for your project.
    @@DEVELOPER_KEY = "AIzaSyAjEkk7g0WFpKwRr1F5Q0lPqsOPNQcU69k"
    @@YOUTUBE_API_SERVICE_NAME = "youtube"
    @@YOUTUBE_API_VERSION = "v3"

  def initialize(options = {})

    sd_default_opts={
      search_str: 'google',
      num_results: 10,
      type_str: 'video,channel,playlist',
      part_str: 'id,snippet'  # this input arg has to be id,snippet for now
    }.merge(options)


    @opts = Trollop::options do
      opt :q, 'Search term', :type => String, :default => sd_default_opts[:search_str]
      # http://stackoverflow.com/questions/16227540/need-help-to-get-more-than-100-results-using-youtube-search-api
      # capping totalResults at 100 (only applicable for v2(?) Haven't tried this myself yet)
      # num_results is sum of videos+channels+playlists
      opt :maxResults, 'Max results', :type => :int, :default => sd_default_opts[:num_results]  
      opt :part, 'parts included', :type => String, :default => sd_default_opts[:part_str]
      opt :type, 'type included', :type => String, :default => sd_default_opts[:type_str]
    end


    @client = Google::APIClient.new(:key => @@DEVELOPER_KEY,
                                   :authorization => nil)
    @youtube = @client.discovered_api(@@YOUTUBE_API_SERVICE_NAME, @@YOUTUBE_API_VERSION)

    @videos = []
    @channels = []
    @playlists = []
  end

  def execute_search
    # Call the search.list method to retrieve results matching the specified
    # query term.
    search_response = @client.execute!(
      :api_method => @youtube.search.list,
      :parameters => @opts
    )
    # Add each result to the appropriate list, and then display the lists of
    # matching videos, channels, and playlists.
    search_response.data.items.each do |search_result|
      case search_result.id.kind
        when 'youtube#video'
          @videos.push({video_title: search_result.snippet.title,
                        video_id: search_result.id.videoId,
                        video_thumbnails_url: search_result.snippet.thumbnails.default.url
                        })
        when 'youtube#channel'
          @channels.push({channel_title: search_result.snippet.title, channel_id: search_result.id.channelId})          
        when 'youtube#playlist'
          @playlists.push({playlist_title: search_result.snippet.title, playlist_id: search_result.id.playlistId})          
      end
    end
  end

end


# require_relative '../config/environment.rb'  # circular requiring, hence the following test is run twice

#   # sd_default_opts={
#   #    search_str: 'google',
#   #    num_results: 10,
#   #    type_str: 'video,channel,playlist',
#   #    part_str: 'id,snippet'  # this input arg has to be id,snippet for now

#   #  search_response.data.items.first.snippet.thumbnails.default.url

# myo = SdYoutubeApi.new(search_str: "dota", type_str: 'video', num_results: 5)
# myo.execute_search

# puts myo.videos
# puts myo.videos.size
# puts "======================"


# puts myo.channels
# puts "======================"

# # outputs:
# # {:video_title=>"Dota 2 Fails of the Week - Ep. 113", :video_id=>"-g9uxa2XWMo"}
# # {:video_title=>"Dota 2 - XMG Captains Draft 2.0 - Evil Geniuses vs Team Secret - Game 1", :video_id=>"gOSohcDcws0"}
# # {:video_title=>"Kunkka 3x Kill DotaCinema CD Dota 2", :video_id=>"KoRhtJ7LAVs"}
# # {:video_title=>"Dota 2 Balance of the Bladekeeper (Legendary Juggernaut Set)", :video_id=>"GTxymmrHnBw"}









