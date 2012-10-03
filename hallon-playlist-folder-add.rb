#!/usr/bin/env ruby
# encoding: utf-8

require 'hallon'

## CONFIG
@spotify_user = "facebookemail@gmail.com"
@spotify_password = "PASSWORD_HERE"

# PREDEFINED PLAYLIST OBJECT
@playlists_object = {
    "Playlist 1" => [
        "http://open.spotify.com/track/4kO7mrAPfqIrsKwUOK5BFx",
        "http://open.spotify.com/track/05lBuZWQ2OhQuzoCSIkvUF",
        "http://open.spotify.com/track/7gKIt3rDGIMJDFVSPBnGmj",
        "http://open.spotify.com/track/13YG6auRrYxGdaM2h5jjTv",
        "http://open.spotify.com/track/0hvcIDobOkiw5Xq1SK3dbj"
    ],
    "Playlist 2" => [
        "http://open.spotify.com/track/1auxYwYrFRqZP7t3s7w4um",
        "http://open.spotify.com/track/78AaMLOriBZuohWdUV3IzE",
        "http://open.spotify.com/track/41X10r4A8eevG9KTEcUlNn",
        "http://open.spotify.com/track/4OKXvqtfwlvY2fYJ2lzHPH",
        "http://open.spotify.com/track/6n6jqguEN6AuK6Y0NtfHzi"
    ]
}

## END CONFIG


## Load and wait looper
def loadandwait(obj)
  obj.load(5)
rescue Interrupt
  puts "Interrupted!"
  exit
rescue Exception => e
  puts e.message
  retry
end


begin
## Initialize Spotify Session
  session = Hallon::Session.initialize IO.read('./spotify_appkey.key'), {:load_playlists => true, :tracefile => './trace.log'}
  session.login! @spotify_user, @spotify_password

  ## Get User Container
  print "Getting Spotify container for #{@spotify_user}..."
  container = session.container
  loadandwait(container)
  puts "Done."

  ## Create Folder at position / index zero
  playlist_folder = container.insert_folder 0, "Hallon Playlists"

  ## Create Playlists
  puts "Creating 'Hallon Playlists' folder in Spotify..."
  @playlists_object.reverse_each do |playlist_label, tracks|

    ## Create Playlist
    playlist = container.add "#{playlist_label}", true

    ## Playlist will be at the last index of the container, move to index 1 -- this pushes playlist_folder.end down
    container.move(container.size-1, 1)

    ## Create Hallon::Track for each spotify URL, insert into playlist
    playlist.insert(0, tracks.map { |x| Hallon::Track.new(x) })
    if playlist.size > 0 then
      ## Upload playlist
      print "\tUploading playlist: #{playlist_label}..."
      begin
        print '.'
        playlist.upload(30)
        STDOUT.flush
      rescue Exception => e
        retry
      end
      puts "Done!"
    else
      ## Remove playlist from container
      container.remove(1)
    end
  end
rescue Exception => e
  puts e.message
  puts e.backtrace
rescue Interrupt
  puts "Interrupted!"
  exit
end
