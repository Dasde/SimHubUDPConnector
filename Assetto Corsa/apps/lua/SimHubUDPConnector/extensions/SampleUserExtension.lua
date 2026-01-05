--[[ 
    RENAME THIS FILE TO UserExtension.lua TO ACTIVATE IT 
]]
UserExtension = {}


local carState = ac.getCar(0)
local sim = ac.getSim()

function UserExtension:update(dt, customData)
--[[ 
    RENAME THIS FILE TO UserExtension.lua TO ACTIVATE IT 
]]
    -- here you can add the properies you need 
    -- example :
    -- customData.AmbientTemperature = sim.ambientTemperature
    -- customData.Autoclutch = carState.autoClutch
end

return UserExtension