local SIM = ac.getSim()
local CAR = ac.getCar(0)
local FuelBase = CAR.fuel
local LastFuel = CAR.fuel
local StintStartLap = 0
local StintTimer = 0
local BoxPos = CAR.pitTransform.position

local connection = {}
local carId = ac.getCarID(0)
local Ignition_RSS = ac.connect({
    ac.StructItem.key(carId .. "_Ignition" .. "_" .. 0),
    Mode = ac.StructItem.int32()
}, true, ac.SharedNamespace.Shared)

local GTMSystemKey = carId .. "_GTMSystem"
local ConnectsharedData = {
    ac.StructItem.key(GTMSystemKey .. "_" .. 0),
	AutoKill = ac.StructItem.boolean(),
	AntiStall = ac.StructItem.boolean(),
    AutoStart = ac.StructItem.boolean(),
    ThrottleMap = ac.StructItem.int32(),
    EngineStarter = ac.StructItem.boolean(),
    PopupTime = ac.StructItem.float(),
    LapChangeTime = ac.StructItem.float(),
    PitLimitSpeed = ac.StructItem.int32(),
	LaunchControl = ac.StructItem.boolean(),
	ICERunning = ac.StructItem.boolean(),
    AirJackPos = ac.StructItem.float(),
}
local GTMSystem = ac.connect(ConnectsharedData, true, ac.SharedNamespace.Shared)

function script.FuelUsed()
	if SIM.isInMainMenu or LastFuel < CAR.fuel then
		FuelBase = CAR.fuel
	end

	LastFuel = CAR.fuel
	return FuelBase - CAR.fuel
end

function connection:carScript(customData)

	if CAR.isInPit and CAR.speedKmh < 1 then
		StintStartLap = CAR.lapCount
		StintTimer = 0
	end
    StintTimer = StintTimer + ac.getDeltaT()
    customData.IgnitionMode = Ignition_RSS.Mode
	customData.FuelUsed = script.FuelUsed()
    customData.STINT = tostring(CAR.lapCount - StintStartLap + 1)
    customData.MIN = string.format("%02d",math.floor((StintTimer/60)%60))
    customData.EngineLifeLeft = CAR.engineLifeLeft
    customData.BoxDistance = math.distance(BoxPos,CAR.position)
    addCarData(GTMSystem, ConnectsharedData, 'GTMSystem_', customData)
end

return connection
