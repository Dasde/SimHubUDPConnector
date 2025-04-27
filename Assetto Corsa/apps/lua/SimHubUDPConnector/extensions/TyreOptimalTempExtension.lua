-- Extension created by Mark Hannon
-- Does not work with replays
---@diagnostic disable: param-type-mismatch
require("extensions.Extension")

TyreOptimalTempExtension = {}

function TyreOptimalTempExtension:new(o)
	o = o or Extension:new(o)
	setmetatable(o, self)
	self.__index = self
	return o
end

local carState = ac.getCar(0)
local carsUtils = require('shared/sim/cars') -- required for tyre.ini data
local wheelsState = carState.wheels ---@type ac.StateWheel
-- local cspVersion = ac.getPatchVersion()

---Return an estimated maximumOptimalTemperature based on compoundName
---and the basic minimalOptimalTemperature.   Simple algorithm based on
---name of the compound and known characteristics.
---
---@param compoundName string name of the compound
---@param minTemp number minimalOptimalTemperature
---@return number maximumOptimalTemperature
local function maximumOptimalTemperature(compoundName, minTemp)
	if (compoundName == nil) then
		-- in replays those values are nil
		return minTemp and (minTemp + 30) or 80
	end
	if string.find(compoundName, "Street") then
		return minTemp + 10
	elseif string.find(compoundName, "Intermediate") then
		return minTemp + 10
	elseif string.find(compoundName, "Wet") then
		return minTemp + 10
	elseif string.find(compoundName, "Super") then
		return minTemp + 15
	elseif string.find(compoundName, 'Soft') then
		return minTemp + 20
	elseif string.find(compoundName, 'Medium') then
		return minTemp + 20
	elseif string.find(compoundName, 'Hard') then
		return minTemp + 25
	else
		return minTemp + 30
	end
end
--- END

function TyreOptimalTempExtension:update(dt, customData)
	customData.TyreCompound = ac.getTyresLongName(0, carState.compoundIndex)
	customData.IdealPressureFront = carsUtils.getTyreConfigValue(carState.compoundIndex, true, "PRESSURE_IDEAL", 0)
	customData.IdealPressureRear = carsUtils.getTyreConfigValue(carState.compoundIndex, false, "PRESSURE_IDEAL", 0)
	customData.MinimumOptimalTemperature = wheelsState[0].tyreOptimumTemperature
	customData.MaximumOptimalTemperature = maximumOptimalTemperature(customData.TyreCompound,
		customData.MinimumOptimalTemperature)
	if ac.getPatchVersionCode() >= 3334 then
		-- if (cspVersion:versionCompare("0.2.7") > -1) then
		-- TemperatureMultiplier shows fraction of optimum grip
		customData.WheelFLTemperatureMultiplier = wheelsState[0].temperatureMultiplier
		customData.WheelFRTemperatureMultiplier = wheelsState[1].temperatureMultiplier
		customData.WheelRLTemperatureMultiplier = wheelsState[2].temperatureMultiplier
		customData.WheelRRTemperatureMultiplier = wheelsState[3].temperatureMultiplier
		-- IsHot shows if the tyres is considered hot
		customData.WheelFLIsHot = wheelsState[0].isHot
		customData.WheelFRIsHot = wheelsState[1].isHot
		customData.WheelRLIsHot = wheelsState[2].isHot
		customData.WheelRRIsHot = wheelsState[3].isHot
	else
		customData.TyreOptimalTempExtensionError = "Please upgrade your csp to version 0.2.7 min."
	end
end

return TyreOptimalTempExtension
