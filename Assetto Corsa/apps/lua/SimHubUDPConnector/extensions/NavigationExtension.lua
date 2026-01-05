NavigationExtension = {}

local carState = ac.getCar(0)

function NavigationExtension:update(dt, customData)
  local turn = ac.getTrackUpcomingTurn(carState.index)
  local trackSector = ac.getTrackSectorName(carState.splinePosition)
  if trackSector == '' then trackSector = 'Unknown' end
  local statusText
  if turn.x == 0 then
    statusText = string.format('Now • %s', trackSector)
  else
    statusText = turn.x ~= -1 and string.format('%.0f m • %s', math.ceil(turn.x / 25) * 25, trackSector) or ''
  end
  local arrowAngle = turn.y
  customData.NavExt_UpcomingTurnDistance = math.ceil(turn.x / 25) * 25
  customData.NavExt_TrackSector = trackSector
  customData.NavExt_Status = statusText
  customData.NavExt_NavArrowAngle = arrowAngle
end

return NavigationExtension
