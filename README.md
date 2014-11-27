Visit the page
=============
http://sd-youtube-project.herokuapp.com/show-me-groups

## Getting Started

1. `bundle install`
2. `shotgun -p 3000 -o 0.0.0.0`
3. Visit `http://localhost:3000/` in your browser

Layout generated from `http://www.layoutit.com/`

## TO DO LIST:
- authenticate useing youtube logins
- ability to change quality, 360p 480p etc
- fast forward button / rewind functionality, link to keybord shortcuts (disablekb=0) 
```
    Spacebar:  Play / Pause
    Arrow Left:  Jump back 5s in the current video
    Arrow Right:  Jump ahead 5s in the current video
    Arrow Up:  Volume up 5%
    Arrow Down:  Volume Down 5%
    enablejsapi allows you to enable the Javascript API to control the YouTube player. If you need this parameter     (which is “1” to enable and “0” by default incidentally)
```
- refractor the code
- improve algorithm (need refractor)
- need refractor for real deployment, remember to remove DEVELOPER_KEY from source code (look at dotenv gem)
- BUG in <%= str=video[:video_title_game]; str.match(/[Gg]ame (\d+)/).captures[0].to_i - 1 unless str.nil? %>, IF THERE IS GAME 1, 3, 4 then it wont match the db  (ONLY APPLICABLE FOR SPY VIEW) (IE NEED TO VALIDATE THE GAME NUMBERS BEFORE ENTERING THE DB)
