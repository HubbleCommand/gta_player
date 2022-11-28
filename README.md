# gta_player

A Flutter app to play GTA radio stations, following a nearly identical formatting to https://github.com/HubbleCommand/GTARadioPi and https://github.com/HubbleCommand/GTARadio.

There are some additional file requirements from the other repos:
- Per station
    - icon.png (optional)       : the icon that will be shown
    - name.txt                  : a text file containing only the name of the station to be displayed
    - /station/songs/mp3tag.csv : (split & talkshow stations) a metadata file generated with MP3Tag to export the song names to a separate file (split & talk show stations)
    - /station/mono/mp3tag.csv  : (split & talkshow stations) same as above

Stations and other assets are kept as separate files to avoid excessive build times & application size (15 minutes & 7 gb).
