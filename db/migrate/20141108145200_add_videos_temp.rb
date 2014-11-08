class AddVideosTemp < ActiveRecord::Migration
  def change
    create_table :videos do |t|
      t.string :video_id
      t.string :video_title
      t.string :video_title_body
      t.string :video_title_game
      t.float :relevance
      t.belongs_to :video_group
    end

    create_table :video_groups do |t|
      t.string :group_title
      t.float :avg_relevance
    end
  end
end