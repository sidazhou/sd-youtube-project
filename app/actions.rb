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

get '/show-me-groups/:video_id' do  ######## DK vs iG G-League 2014
  # to get the video into iframe
  video_id_temp = params[:video_id]


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

# # For testing, use tux, not implemented
  Video.delete_all # resetting db

  # populating videos table
  game_regex  = /[Gg]ame \d/ # used in the loop below
  sd_obj.videos.each_with_index { |video,index|
    Video.create( video_id: video[:video_id], 
                  video_title: video[:video_title],
                  video_title_body: video[:video_title].force_encoding("UTF-8").gsub(game_regex,''),
                  video_title_game: video[:video_title].force_encoding("UTF-8")[game_regex],
                  relevance: index,
                  video_thumbnails_url: video[:video_thumbnails_url]
                )
  }

  # populating video_groups table
  VideoGroup.delete_all # resetting db

  ActiveRecord::Base.establish_connection(
    :adapter => 'sqlite3',
    :database => "db/db.sqlite3"
  )

        table_name = "video_groups"  # resetting db
        new_max = 0
        update_seq_sql = "update sqlite_sequence set seq = #{new_max} where name = '#{table_name}';"
        ActiveRecord::Base.connection.execute(update_seq_sql)

  puts ActiveRecord::Base.connection.exec_query("INSERT INTO video_groups (group_title, avg_relevance) SELECT video_title_body, AVG(relevance) FROM videos GROUP BY video_title_body;").collect &:values

  # linking video.video_group_id with video_groups.id
  Video.all.each do |video|
    VideoGroup.all.each do |video_group|
      if  video_group.group_title == video.video_title_body
            video.update(video_group_id: video_group.id)
      end
    end
  end

  # now the models and db are in place. Rendering next
  @all_video_groups = VideoGroup.all.order(:avg_relevance)
  # # delete all series with only 1 game in it, to make things look better
  # @all_video_groups.each do |vg|  ############################
  #   if vg.videos.count <= 1
  #     vg.destroy
  #   end
  # end
  # # re-assigning the variable in memory based on the db
  # @all_video_groups = VideoGroup.all.order(:avg_relevance).limit(5)


  #if clicked on the groups
  if !params[:video_group_id].nil? #if passed this argument in url, only happens when group is clicked
    @video_group_id = params[:video_group_id]
    # @related_videos is the videos in the same group
    @related_videos = Video.where(video_group_id: @video_group_id).order(:video_title_game)
  end

  if !params[:video_group_id].nil? && !params[:game].nil? 
    #then overwrite the default
    # EDIT: DO NOT OVERWRITE THE DEFAULT
    game_num = params[:game].to_i
    # video_id_NEW is only defined when group is clicked in <div class="box_below_main"> 
    @video_id_NEW = @related_videos[game_num][:video_id]
    @video_title_NEW = @related_videos[game_num][:video_title]
  end

  erb :'show-me-groups'
end


post '/show-me-groups' do
  redirect '/show-me-groups/' + params[:searched_str]
end

get '/show-me-groups/video/link/:video_id' do
  # puts params[:video_id]
  redirect '/show-me-groups/' + params[:video_id] + "?video_group_id=" + params[:video_group_id] +"&game=" + params[:game]
end




