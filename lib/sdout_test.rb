# search term: DK vs iG G-League 2014

require 'pry'
arr = []
counter = 0

file = File.new("./sdout.txt", "r")
while (line = file.gets)

    game_regex  = /[Gg]ame \d/
    
    video_hash = {}
    video_hash[:id] = 666 # NOT IMPLEMENTED
    video_hash[:title] = line
    # video_hash[:title_body] = line.force_encoding("UTF-8").gsub(game_regex,'')
    video_hash[:title_body] = line.force_encoding("UTF-8").gsub(game_regex,'')
    video_hash[:title_game] = line.force_encoding("UTF-8")[game_regex]
    video_hash[:relevance] = counter # since the videos are returned in the order of relevance by default by youtube api
    counter += 1

    arr << video_hash
    # puts "#{line}"
end
file.close

arr.each { |h| 
  # puts h
  # puts h[:title]
  puts h[:title_body]
  # puts h[:relevance]
}

# building video_groups
# arr of hashes





# arr = %w{ a b c }
# p arr.index("c")









