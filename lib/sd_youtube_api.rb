# https://developers.google.com/youtube/v3/code_samples/ruby#search_by_keyword

class SdYoutubeApi
  attr_reader :videos, :channels, :playlists
    # Set DEVELOPER_KEY to the "API key" value from the "Access" tab of the
    # Google Developers Console <https://cloud.google.com/console>
    # Please ensure that you have enabled the YouTube Data API for your project.
    DEVELOPER_KEY = "AIzaSyAjEkk7g0WFpKwRr1F5Q0lPqsOPNQcU69k"
    YOUTUBE_API_SERVICE_NAME = "youtube"
    YOUTUBE_API_VERSION = "v3"

  def initialize(search_str='google',num_results='10')

    @opts = Trollop::options do
      opt :q, 'Search term', :type => String, :default => search_str
      opt :maxResults, 'Max results', :type => :int, :default => num_results
    end

    @client = Google::APIClient.new(:key => DEVELOPER_KEY,
                                   :authorization => nil)
    @youtube = @client.discovered_api(YOUTUBE_API_SERVICE_NAME, YOUTUBE_API_VERSION)

    @videos = []
    @channels = []
    @playlists = []
  end

  def execute_search
    # Call the search.list method to retrieve results matching the specified
    # query term.
    @opts[:part] = 'id,snippet'
    search_response = @client.execute!(
      :api_method => @youtube.search.list,
      :parameters => @opts
    )

    # Add each result to the appropriate list, and then display the lists of
    # matching videos, channels, and playlists.
    search_response.data.items.each do |search_result|
      case search_result.id.kind
        when 'youtube#video'
          @videos.push({video_title: search_result.snippet.title, video_id: search_result.id.videoId})          
        when 'youtube#channel'
          @channels.push({channel_title: search_result.snippet.title, channel_id: search_result.id.channelId})          
        when 'youtube#playlist'
          @playlists.push({playlist_title: search_result.snippet.title, playlist_id: search_result.id.playlistId})          
      end
    end
  end

end


# require_relative '../config/environment.rb'
# myo = SdYoutubeApi.new("dota cinema",10)
# myo.execute_search
# puts myo.videos
# puts "======================"
# puts myo.channels
# puts "======================"

# # outputs:
# # {:video_title=>"Dota 2 Fails of the Week - Ep. 113", :video_id=>"-g9uxa2XWMo"}
# # {:video_title=>"Dota 2 - XMG Captains Draft 2.0 - Evil Geniuses vs Team Secret - Game 1", :video_id=>"gOSohcDcws0"}
# # {:video_title=>"Kunkka 3x Kill DotaCinema CD Dota 2", :video_id=>"KoRhtJ7LAVs"}
# # {:video_title=>"Dota 2 Balance of the Bladekeeper (Legendary Juggernaut Set)", :video_id=>"GTxymmrHnBw"}
