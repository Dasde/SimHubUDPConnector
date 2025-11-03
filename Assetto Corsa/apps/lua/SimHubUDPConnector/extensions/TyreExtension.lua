-- Extension created by Mark Hannon <mark.hannon@gmail.com>
--
-- Does not work with replays
-- 
-- Compute the optimal tyre temperature
-- Generates leaderboard style properties for SimHub dashboards
-- that are missing from standard data.   Currently sends tyre
-- compound data as this is not available otherwise. 
---@diagnostic disable: param-type-mismatch
require("extensions.Extension")

TyreExtension = {}

function TyreExtension:new(o)
	o = o or Extension:new(o)
	setmetatable(o, self)
	self.__index = self
	return o
end

local carState = ac.getCar(0)
local carsUtils = require('shared/sim/cars') -- required for tyre.ini data
local wheelsState = carState.wheels ---@type ac.StateWheel

---Return an estimated maximumOptimalTemperature based on compoundName
---and the basic minimalOptimalTemperature.   Simple algorithm based on
---name of the compound and known characteristics.
---
---@param compoundName string name of the compound
---@param minTemp number minimalOptimalTemperature
---@return number|nil maximumOptimalTemperature
local function maximumOptimalTemperature(compoundName, minTemp)
	if (compoundName == nil) then
		-- in replays those values are nil
		return nil
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

-- Constant to define minimum time between updates
local MINIMUM_TIME_BETWEEN_UPDATES = 1

-- helper function to format position with two digits
local function _idx(i)
	return string.format("%02d", tostring(i))
end

-- helper function to split cars table into one with
-- connected cars and one with unconnected cars
local function classifyCars(cars)
	local _connected = {}
	local _unconnected = {}
	for i, carIndex in ipairs(cars) do
		if (ac.getCar(carIndex).isConnected == true) then
			table.insert(_connected, carIndex)
		else
			table.insert(_unconnected, carIndex)
		end
	end
	return _connected, _unconnected
end

-- Sort function to sort a table of car_ids by bestLapTimeMs
-- Used in practice and qualify sessions
local function sortCarsByTime(left, right)
	return ac.getCar(left).bestLapTimeMs < ac.getCar(right).bestLapTimeMs
end

-- Sort function to sort a table of car_ids by lapCount + splinePosition
-- Used in race sessions to determine position order.
local function sortCarsByPosition(left, right)
	return (ac.getCar(left).lapCount + ac.getCar(left).splinePosition) >
	(ac.getCar(right).lapCount + ac.getCar(right).splinePosition)
end

-- Table of cars used to store car_id in sorted list
-- Seperate tables for connected and unconnectedCars
local cars = {}
local carsConnected = {}
local carsNotConnected = {}
for i, car in ac.iterateCars() do
	table.insert(cars, car.index)
end

-- Timestamp to delay expensive sort operations
local timeSinceLastUpdate = 0

function TyreExtension:update(dt, customData)
	customData.TyreCompound = ac.getTyresName(0, carState.compoundIndex)
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

	-- Leaderboard
	timeSinceLastUpdate = timeSinceLastUpdate + dt
	local car
	if (timeSinceLastUpdate > MINIMUM_TIME_BETWEEN_UPDATES) then

		-- Create seperate tables of connected and not-connected cars
		carsConnected, carsNotConnected = classifyCars(cars)

		-- Sort the connected car table as per appropriate rules for session.
		if (ac.getSim().raceSessionType == 3) then
			table.sort(carsConnected, sortCarsByPosition)
		else
			table.sort(carsConnected, sortCarsByTime)
		end

		-- Update the tyre data for connected cars
		for i, carIndex in ipairs(carsConnected) do
			car = ac.getCar(carIndex)
			customData["Position_" .. _idx(i) .. "_TyreCompound"] = ac.getTyresName(carIndex, car.compoundIndex)
		end

		-- Clear the tyre data for unconnected cars
		local offset = #carsConnected
		for i, carIndex in ipairs(carsNotConnected) do
			customData["Position_" .. _idx(i+offset) .. "_TyreCompound"] = nil
		end

		timeSinceLastUpdate = 0
	end
end

return TyreExtension
