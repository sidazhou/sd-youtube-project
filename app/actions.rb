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
  redirect '/show-me-all/' + default_url
end

get '/show-me-all/:video_id' do  ######## dYTNwbMYcUg
  # to get the video into iframe
  video_id_temp = params[:video_id]

  # to get other videos, since I need to 
  # 1) get the video_title, using one search
  # 2) use the video_title in 2nd search to get other videos
  sd_obj = SdYoutubeApi.new(search_str: video_id_temp, num_results: 1, type_str: 'video')
  sd_obj.execute_search
  @video_id = sd_obj.videos.first[:video_id]  
  @video_title = sd_obj.videos.first[:video_title]  
  
  sd_obj = SdYoutubeApi.new(search_str: @video_title, num_results: 7, type_str: 'video')
  sd_obj.execute_search
  @all_other_videos = sd_obj.videos.select { |video| video[:video_title] != @video_title }


  erb :'show-me-all'
end


post '/show-me-all' do
  redirect '/show-me-all/' + params[:searched_str]
end

get '/show-me-all/video/link/:video_id' do
  # puts params[:video_id]
  redirect '/show-me-all/' + params[:video_id]
end