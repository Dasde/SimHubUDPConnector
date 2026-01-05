WheelExtension = {}

local carState = ac.getCar(0)
local wheelsState = carState.wheels

function WheelExtension:update(dt, customData)
    local prefix
    local wheel
    for i = 0, 3, 1 do
        wheel = wheelsState[i]
        prefix = "WheelExt_" .. i .. "_"
        addProp(prefix, wheel, "tyreWidth", customData)
        addProp(prefix, wheel, "rimRadius", customData)
        addProp(prefix, wheel, "tyreDirty", customData)
        addProp(prefix, wheel, "tyreWear", customData)
        addProp(prefix, wheel, "tyreVirtualKM", customData)
        addProp(prefix, wheel, "tyreGrain", customData)
        addProp(prefix, wheel, "tyreBlister", customData)
        addProp(prefix, wheel, "tyreFlatSpot", customData)
        addProp(prefix, wheel, "tyreStaticPressure", customData)
        addProp(prefix, wheel, "tyrePressure", customData)
        addProp(prefix, wheel, "temperatureMultiplier", customData)
        addProp(prefix, wheel, "tyreCoreTemperature", customData)
        addProp(prefix, wheel, "tyreInsideTemperature", customData)
        addProp(prefix, wheel, "tyreMiddleTemperature", customData)
        addProp(prefix, wheel, "tyreOutsideTemperature", customData)
        addProp(prefix, wheel, "tyreOptimumTemperature", customData)
        addProp(prefix, wheel, "discTemperature", customData)
        addProp(prefix, wheel, "angularSpeed", customData)
        addProp(prefix, wheel, "slip", customData)
        addProp(prefix, wheel, "slipAngle", customData)
        addProp(prefix, wheel, "slipRatio", customData)
        addProp(prefix, wheel, "ndSlip", customData)
        addProp(prefix, wheel, "load", customData) 
        addProp(prefix, wheel, "loadK", customData)
        addProp(prefix, wheel, "speedDifference", customData)
        addProp(prefix, wheel, "camber", customData) 
        addProp(prefix, wheel, "toeIn", customData) 
        addProp(prefix, wheel, "suspensionDamage", customData)
        addProp(prefix, wheel, "suspensionTravel", customData)
        addProp(prefix, wheel, "tyreLoadedRadius", customData)
        addProp(prefix, wheel, "waterThickness", customData)
        addProp(prefix, wheel, "dx", customData)
        addProp(prefix, wheel, "dy", customData)
        addProp(prefix, wheel, "mz", customData)
        addProp(prefix, wheel, "fx", customData)
        addProp(prefix, wheel, "fy", customData)
        addProp(prefix, wheel, "contactNormal", customData)
        addProp(prefix, wheel, "contactPoint", customData)
        addProp(prefix, wheel, "position", customData)
        addProp(prefix, wheel, "look", customData)
        addProp(prefix, wheel, "up", customData)
        addProp(prefix, wheel, "outside", customData)
        addProp(prefix, wheel, "velocity", customData)
        addProp(prefix, wheel, "transform", customData)
        addProp(prefix, wheel, "transformWheel", customData)
        addProp(prefix, wheel, "surfaceDirt", customData)
        addProp(prefix, wheel, "surfaceSectorID", customData)
        addProp(prefix, wheel, "surfaceSectionIndex", customData)
        addProp(prefix, wheel, "surfaceGrip", customData)
        addProp(prefix, wheel, "surfaceDamping", customData)
        addProp(prefix, wheel, "surfaceGranularity", customData)
        addProp(prefix, wheel, "surfaceVibrationGain", customData)
        addProp(prefix, wheel, "surfaceVibrationLength", customData)
        addProp(prefix, wheel, "surfacePitlane", customData)
        addProp(prefix, wheel, "surfaceValidTrack", customData)
        addProp(prefix, wheel, "isBlown", customData)
        addProp(prefix, wheel, "isHot", customData)
        addProp(prefix, wheel, "isSpecialSurface", customData)
        addProp(prefix, wheel, "surfaceType", customData)
        if ac.getPatchVersionCode() >= 3334 then
            addProp(prefix, wheel, "surfaceExtendedType", customData)
        else
            customData.WheelSurfaceError = "Please upgrade your csp to version 0.2.7 min."
        end
    end
end

return WheelExtension