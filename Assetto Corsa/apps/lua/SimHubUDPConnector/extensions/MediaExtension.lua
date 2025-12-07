require("extensions.Extension")

MediaExtension = {}

function MediaExtension:new (o)
    o = o or Extension:new(o)
    setmetatable(o, self)
    self.__index = self
    return o
 end

local function time(value)
  if value == -1 then return '--:--' end
  return string.format('%02d:%02d', math.floor(value / 60), math.floor(value % 60))
end

function MediaExtension:update(dt, customData)
    local mediaData = ac.currentlyPlaying()
    customData.MediaExt_MediaIsPlaying = mediaData.isPlaying
    customData.MediaExt_MediaTitle = mediaData.title
    customData.MediaExt_MediaArtist = mediaData.artist
    customData.MediaExt_MediaAlbum = mediaData.album
    customData.MediaExt_MediaLength = string.format('%s', time(mediaData.trackDuration))
    customData.MediaExt_MediaAlbumTrackCount = mediaData.albumTracksCount
    customData.MediaExt_MediaAlbumTrackNumber = mediaData.trackNumber
    customData.MediaExt_MediaSourceId = mediaData.sourceID
    customData.MediaExt_MediaHasCover = mediaData.hasCover
    customData.MediaExt_MediaElapsed = string.format('%s', time(mediaData.trackPosition))
    customData.MediaExt_MediaElapsedPercent = mediaData.trackDuration > 0 and math.min(mediaData.trackPosition / mediaData.trackDuration * 100, 100) or 0
end

return MediaExtension