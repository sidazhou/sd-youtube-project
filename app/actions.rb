# enable :sessions

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

# ###########################################################

get '/show-me-all' do
  redirect '/show-me-all/' + default_url
end

get '/show-me-all/:video_id' do  ######## DK vs iG G-League 2014
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

# ###########################################################

get '/show-me-groups' do
  redirect '/show-me-groups/' + default_url
end

get '/show-me-groups/:video_id' do  
  # to get the video into iframe
  video_id_temp = params[:video_id]
# video_id_temp = 'PV4H8bWqDds' ######## DK%20vs%20iG%20G-League%202014   

  # to get other videos, since I need to 
  # 1) get the video_title, using one search
  # 2) use the video_title in 2nd search to get other videos
  sd_obj = SdYoutubeApi.new(search_str: video_id_temp, num_results: 1, type_str: 'video')
  sd_obj.execute_search
  @video_id = sd_obj.videos.first[:video_id]
  @video_title = sd_obj.videos.first[:video_title]  
  
  sd_obj = SdYoutubeApi.new(search_str: @video_title, num_results: 50, type_str: 'video')
  sd_obj.execute_search
  
  # from before # 
  @all_other_videos = sd_obj.videos.select { |video| video[:video_title] != @video_title }

  # populating video_table
  game_regex  = /[Gg]ame \d/ # used in the loop below
  video_table = sd_obj.videos

  video_table.each_with_index do |video,index|
    video[:id] = index
    video[:relevance] = index
    video[:video_title_body] = video[:video_title].force_encoding("UTF-8").gsub(game_regex,'')
    video[:video_title_game] = video[:video_title].force_encoding("UTF-8")[game_regex]
  end

  # instead of Video model, now i have video_table, which is arr of hashes
  # instead of VideoGroup model, now i have video_group_table, which is arr of hashes

  # SORTING the video_table, https://www.ruby-forum.com/topic/194331
  video_table.sort! do |video1 , video2|
    first  =   video1[:video_title_body] <=> video2[:video_title_body]   #first condition
    second =   video1[:video_title_game] <=> video2[:video_title_game]   #second condition

    first.zero? ? second : first #if they are equal on first
                                 #then return second
  end
  @video_table = video_table

  # BUILDING the video_group_table
  video_group_table = []

  index_vg = 0
  video_group_table[index_vg] = {} #initialize, otherwise you cant assign
  video_group_table[index_vg][:id] = index_vg #initialize, otherwise you cant assign
  video_group_table[index_vg][:video_count] = 0
  video_group_table[index_vg][:avg_relevance] = 0
  video_group_table[index_vg][:group_title] = video_table.first[:video_title_body]

  video_table.each_with_index do |video,index_v|

    if video[:video_title_body] == video_group_table[index_vg][:group_title]
      video[:video_group_id] = video_group_table[index_vg][:id]
      video_group_table[index_vg][:video_count] = video_group_table[index_vg][:video_count] + 1
      video_group_table[index_vg][:avg_relevance] = (video_group_table[index_vg][:avg_relevance] + video[:relevance] ) / video_group_table[index_vg][:video_count]
    else #else create next video_group
      index_vg = index_vg + 1
      video_group_table[index_vg] = {} #initialize, otherwise you cant assign
      video_group_table[index_vg][:id] = index_vg #initialize, otherwise you cant assign
      video_group_table[index_vg][:video_count] = 0
      video_group_table[index_vg][:avg_relevance] = 0
      video_group_table[index_vg][:group_title] = video[:video_title_body]
      redo # restart this iteration of the loop?
    end

  end #end each

  # SORTING the video_group_table
  video_group_table.sort! do |vg1 , vg2|
    vg1[:avg_relevance] <=> vg2[:avg_relevance]
  end

  # now the models and db are in place. Rendering next
  @all_video_groups = video_group_table
  # # delete all series with only 1 game in it, to make things look better
  # @all_video_groups = video_group_table.select do |vg|  #hash
  #   vg[:video_count] > 1
  # end[0..4] # limit(5), seem to be ordered already so .order(:avg_relevance) is not needed


  if !params[:video_group_id].nil? #if passed this argument in url, only happens when group is clicked
    @video_group_id = params[:video_group_id]
    # @related_videos is the videos in the same group
    @related_videos = video_table.select { |v| v[:video_group_id] == @video_group_id.to_i } #maybe its already ordered, so no need .order(:video_title_game)
  end

  if !params[:video_group_id].nil? && !params[:game].nil? 

    # then overwrite the default
    # EDIT: DO NOT OVERWRITE THE DEFAULT

    game_num = params[:game].to_i

    # redundant, this is fixed in the button instead of here
    if game_num < 0
      game_num = 0 # happens when we are at first game of the series, negative index means going to the end of our db(?)
    end

    # video_id_NEW is only defined when group is clicked in <div class="box_below_main"> 
    begin
      @video_id_NEW = @related_videos[game_num][:video_id]
      @video_title_NEW = @related_videos[game_num][:video_title]
      @no_more_videos_flag = false
    rescue # happens when we are at last game of the series  # then return the last vid in the db
      @video_id_NEW = @related_videos[-1][:video_id] 
      @video_title_NEW = @related_videos[-1][:video_title]
      @no_more_videos_flag = true
    end
  end
  


  # # hacks to make any search to return grouped results, ie not only on click of the group 
  if params[:video_group_id].nil? || params[:game].nil? 
    redirect '/show-me-groups/' + params[:video_id] + "?video_group_id=" + video_table.select { |v| v[:video_id] == @video_id}.first[:video_group_id].to_s + "&game=0"
  else
    erb :'show-me-groups'
  end
end


post '/show-me-groups' do
  redirect '/show-me-groups/' + params[:searched_str]
end

get '/show-me-groups/video/link/:video_id' do
  # puts params[:video_id]
  redirect '/show-me-groups/' + params[:video_id] + "?video_group_id=" + params[:video_group_id] +"&game=" + params[:game]
end




