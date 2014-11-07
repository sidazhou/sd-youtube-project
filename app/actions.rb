# Homepage (Root path)
get '/' do
  erb :index
end

get '/ifeellucky' do
  @video_id = "3cWpo5BoahA"  #like a default

  erb :'ifeellucky'
end

post '/ifeellucky' do
  # puts params[:searched_str]
  
  sd_obj = SdYoutubeApi.new(params[:searched_str],1,'video')
  sd_obj.execute_search

  # puts sd_obj.videos.first[:video_title]
  # puts sd_obj.videos.first[:video_title].class
  # puts sd_obj.videos.first[:video_id]

  @video_id = sd_obj.videos.first[:video_id]  # this is the video returned by search


  erb :'ifeellucky'
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