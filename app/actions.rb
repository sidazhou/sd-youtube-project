# Homepage (Root path)
get '/' do
  erb :index
end

get '/i-feel-lucky' do
  @video_id = default_url  #like a default

  erb :'i-feel-lucky'
end

post '/i-feel-lucky' do
  sd_obj = SdYoutubeApi.new(search_str: params[:searched_str], num_results: 1, type_str: 'video')
  sd_obj.execute_search

  @video_id = sd_obj.videos.first[:video_id]  # this is the video returned by search

  erb :'i-feel-lucky'
end

get '/show-me-all' do
  @video_id = default_url  #like a default

  erb :'show-me-all'
end


post '/show-me-all' do
  sd_obj = SdYoutubeApi.new(search_str: params[:searched_str], num_results: 7, type_str: 'video')
  sd_obj.execute_search

  @video_id = sd_obj.videos.first[:video_id]  # this is the video returned by search
  @video_title = sd_obj.videos.first[:video_title]  

  @all_other_videos = sd_obj.videos[1..-1] # all other video, arr of obj

  erb :'show-me-all'
end

