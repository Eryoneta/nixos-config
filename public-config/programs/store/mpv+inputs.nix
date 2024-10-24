# Content of "config.programs.mpv.bindings" (home-manager)
actions: {

  # Play/Pause
  "MBTN_LEFT" = actions.togglePause; # mouse_left
  "Space" = actions.togglePause; # space
  "PLAY" = actions.togglePause; # media_play
  "PAUSE" = actions.togglePause; # media_pause
  "PLAYPAUSE" = actions.togglePause; # media_play_pause

  "PLAYONLY" = actions.play; # media_play_only
  "PAUSEONLY" = actions.pause; # media_pause_only

  # Fullscreen
  "MBTN_LEFT_DBL" = actions.toggleFullscreen; # mouse_left_x2
  "Enter" = actions.toggleFullscreen; # enter
  "Esc" = actions.exitFullscreen; # esc

  # Menu
  "MBTN_RIGHT" = actions.openMenu; # mouse_right
  "o" = actions.openMenu; # o

  # Exit
  "Shift+Esc" = actions.exit; # shift+esc
  "MBTN_MID" = actions.exit; # mouse_middle
  "STOP" = actions.exit; # media_stop
  "POWER" = actions.exit; # power
  "CLOSE_WIN" = actions.exit; # close-window

  # Seek
  "Right" = actions.goForward.small; # right
  "Left" = actions.goBack.small; # left

  "Ctrl+Right" = actions.goForward.medium; # ctrl+right
  "Ctrl+Left" = actions.goBack.medium; # ctrl+left
  
  "FORWARD" = actions.goForward.medium; # media_forward
  "REWIND" = actions.goBack.medium; # media_rewind

  "Ctrl+Shift+Right" = actions.goForward.big; # ctrl+shift+right
  "Ctrl+Shift+Left" = actions.goBack.big; # ctrl+shift+left

  "." = actions.goForward.frame; # .
  "," = actions.goBack.frame; # ,
  
  "End" = actions.goForward.end; # end
  "Home" = actions.goBack.start; # home

  # Volume
  "m" = actions.toggleMute; # m
  "MUTE" = actions.toggleMute; # media_mute

  "WHEEL_UP" = actions.volumeUp; # wheel_up
  "WHEEL_DOWN" = actions.volumeDown; # wheel_down

  "up" = actions.volumeUp; # up
  "down" = actions.volumeDown; # down

  "VOLUME_UP" = actions.volumeUp; # media_volume_up
  "VOLUME_DOWN" = actions.volumeDown; # media_volume_down

  # Audios
  "Ctrl+Shift+a" = actions.openAudioMenu; # ctrl+shift+a

  "a" = actions.nextAudio; # a
  "Shift+a" = actions.prevAudio; # shift+a

  # Subtitles
  "Ctrl+Shift+s" = actions.openSubtitleMenu; # ctrl+shift+s
  "Ctrl+s" = actions.toggleSubtitle; # ctrl+s

  "s" = actions.nextSubtitle; # s
  "Shift+s" = actions.prevSubtitle; # shift+s

  # Playlist
  "l" = actions.openPlaylistMenu; # l

  "PgDwn" = actions.nextFile; # page_down
  "PgUp" = actions.prevFile; # page_up

  "NEXT" = actions.nextFile; # media_next
  "PREV" = actions.prevFile; # media_prev

  # Playback speed
  "Ctrl+0" = actions.resetSpeed; # ctrl+0

  "Ctrl+Up" = actions.speedUp; # ctrl+up
  "Ctrl+Down" = actions.speedDown; # ctrl+down

  # Zoom
  "Alt+Shift+f" = actions.resetZoom; # ctrl+shift+f

  "Alt+f" = actions.zoomIn; # ctrl+f
  "Shift+f" = actions.zoomOut; # shift+f

  "Ctrl+WHEEL_UP" = actions.zoomIn; # ctrl+wheel_up
  "Ctrl+WHEEL_DOWN" = actions.zoomOut; # ctrl+wheel_down

  "Alt+a" = actions.moveLeft; # alt+a
  "Alt+d" = actions.moveRight; # alt+d
  "Alt+w" = actions.moveUp; # alt+w
  "Alt+s" = actions.moveDown; # alt+s

  # Rotate
  "Ctrl+Shift+r" = actions.resetRotation; # ctrl+shift+r

  "Ctrl+r" = actions.rotateClockwise; # ctrl+r
  "Shift+r" = actions.rotateAntiClockwise; # shift+r

  # After end
  "t" = actions.afterPlaying.exit; # t
  "g" = actions.afterPlaying.playNext; # g
  "Ctrl+Alt+d" = actions.afterPlaying.shutdown; # ctrl+alt+d
  "Ctrl+Alt+s" = actions.afterPlaying.suspend; # ctrl+alt+s
  "Ctrl+Alt+h" = actions.afterPlaying.hibernate; # ctrl+alt+h

  # Loop
  "r" = actions.toggleLoop; # r

  # Reverse
  "Alt+r" = actions.toggleReverse; # alt+r

  # Pin
  "p" = actions.togglePin; # p

  # Screenshot
  "F5" = actions.takeScreenshot; # f5

  # Info
  "i" = actions.toggleInfo; # i

  # File
  "Ctrl+o" = actions.openFileMenu; # ctrl+o

  "Ctrl+c" = actions.copyFilePath; # ctrl+c
  "Ctrl+v" = actions.openFileInClipboard; # ctrl+v

}