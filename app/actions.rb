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

  sd_obj = SdYoutubeApi.new(search_str: params[:searched_str], num_results: 1, type_str: 'video')
  sd_obj.execute_search

  # puts sd_obj.videos.first[:video_title]
  # puts sd_obj.videos.first[:video_title].class
  # puts sd_obj.videos.first[:video_id]

  @video_id = sd_obj.videos.first[:video_id]  # this is the video returned by search

  erb :'ifeellucky'
end

# require_relative '../config/environment.rb'  # circular requiring, hence the following test is run twice
#   # sd_default_opts={
#   #    search_str: 'google',
#   #    num_results: 10,
#   #    type_str: 'video,channel,playlist',
#   #    part_str: 'id,snippet'  # this input arg has to be id,snippet for now

# myo = SdYoutubeApi.new(search_str: "dota", type_str: 'video')
# myo.execute_search
# puts myo.videos
# puts myo.videos.size



