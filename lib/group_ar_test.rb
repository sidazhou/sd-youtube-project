# running in tux


Video.all.count

pp Video.all; nil

pp Video.all.order(video_title_body: :asc, video_title_game: :asc); nil


Video.select(:video_title_body).distinct


insert into video_groups (group_title, avg_relevance) select video_title_body, avg(relevance) from videos group by video_title_body;

# use uniqness to bulidin the new table then populate
# Video.first.video_group_id = VideoGroup.first.id
# Video.joins('LEFT JOIN video_groups ON video_groups.group_title = videos.video_group_id')

pp Video.where(video_group_id: 171); nil

VideoGroup.find(171).videos.count

VideoGroup.all.each { |vg| puts vg.videos.count }; nil
VideoGroup.all.each { |vg| puts vg.videos.count; puts vg.avg_relevance }; nil

pp VideoGroup.all.order(:avg_relevance); nil

