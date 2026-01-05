---@diagnostic disable: cast-local-type
OnlineOvertakeExtension = {}

 local DEBUG_ON = true

 -- Overtake
 -- Working on this server at least : 89.11.180.99:8090
 local overtakeTotalScore = 0
 local overtakeComboMeter = 1
 local overtakeCurrentRank = 0
 
 local overtakePersonalBest = 0
 local overtakeOwnRank = 0
 local overtakeLastMessage = ""
 
 local collisionMessages = {"Collision!", "Do you have a good insurance?"}
 local overtakeMessages = {"Overtake!", "Yeah!"}
 local closeOvertakeMessages = {"Close Overtake!", "That Was Close!"}
 local tooSlowMessages = {"Speed Up!", "Too Slow!"}
 
 local overtakeEventType = {
     NONE = 0,
     OVERTAKE = 1,
     COLLISION = 2,
     FINISHED = 3,
     TOO_SLOW = 4,
     CLOSE_OVERTAKE = 5
 }

 local overtakePersonalBestEvent = ac.OnlineEvent({
     ac.StructItem.key("overtakePersonalBest"),
     score = ac.StructItem.int64(),
     rank = ac.StructItem.int32()
 }, function(sender, message)
      if sender ~= nil then return end
     overtakePersonalBest = tonumber(message.score)
     overtakeOwnRank = tonumber(message.rank)
     if (DEBUG_ON) then
         ac.debug("pb", overtakePersonalBest)
         ac.debug("own rank", overtakeOwnRank)
     end
 end, ac.SharedNamespace.ServerScript)
 
 overtakePersonalBestEvent({})
 
 local numUpdates = 0
 local overtakeUpdateEvent = ac.OnlineEvent({
     ac.StructItem.key("overtakeUpdate"),
     score = ac.StructItem.int64(),
     combo = ac.StructItem.float(),
     events = ac.StructItem.array(ac.StructItem.byte(), 10),
     rank = ac.StructItem.int32()
 }, function(sender, message)
     overtakeComboMeter = tonumber(message.combo)
     overtakeTotalScore = tonumber(message.score)
     overtakeCurrentRank = tonumber(message.rank)
 
     if overtakeTotalScore > overtakePersonalBest then
         overtakePersonalBest = overtakeTotalScore
     end
     if     message.events[0] == overtakeEventType.NONE           then overtakeLastMessage = ""
     elseif message.events[0] == overtakeEventType.OVERTAKE       then overtakeLastMessage = overtakeMessages[math.random(#overtakeMessages)]
     elseif message.events[0] == overtakeEventType.CLOSE_OVERTAKE then overtakeLastMessage = closeOvertakeMessages[math.random(#closeOvertakeMessages)]
     elseif message.events[0] == overtakeEventType.TOO_SLOW       then overtakeLastMessage = tooSlowMessages[math.random(#tooSlowMessages)]
     elseif message.events[0] == overtakeEventType.COLLISION      then overtakeLastMessage = collisionMessages[math.random(#collisionMessages)]
     end
     numUpdates = numUpdates + 1
     if (DEBUG_ON) then
         ac.debug("score", overtakeTotalScore)
         ac.debug("combo", overtakeComboMeter)
         ac.debug("rank", overtakeCurrentRank)
         ac.debug("last message", overtakeLastMessage)
         ac.debug("No. of Updates", numUpdates)
     end
 end, ac.SharedNamespace.ServerScript)

function OnlineOvertakeExtension:update(dt, customData)
    customData.OvertakeOwnRank = overtakeOwnRank
    customData.OvertakeCurrentRank = overtakeCurrentRank
    customData.OvertakePersonalBest = overtakePersonalBest
    customData.OvertakeLastMessage = overtakeLastMessage
    customData.OvertakeTotalScore = overtakeTotalScore
    customData.OvertakeComboMeter = overtakeComboMeter

end

return OnlineOvertakeExtension