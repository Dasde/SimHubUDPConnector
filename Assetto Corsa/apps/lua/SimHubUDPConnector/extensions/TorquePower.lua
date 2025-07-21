require("extensions.Extension")

TorquePower = {}

local basePath = ac.dirname() .. "/../../../content/cars/"


local function readFile(path)
    local file = io.open(path, "r")
    if not file then return nil end
    local content = file:read("*all")
    file:close()
    return content
end

local function extractCompleteArray(text, startPos)
    local bracketLevel = 0
    local i = startPos
    local arrayEnd = nil

    while i <= #text do
        local char = text:sub(i, i)
        if char == "[" then
            bracketLevel = bracketLevel + 1
        elseif char == "]" then
            bracketLevel = bracketLevel - 1
            if bracketLevel == 0 then
                arrayEnd = i
                break
            end
        end
        i = i + 1
    end

    if arrayEnd then
        return text:sub(startPos, arrayEnd)
    else
        return nil
    end
end

local function parseCurveArray(text, arrayName)
    local array = {}

    local startPos = text:find('"' .. arrayName .. '"%s*:%s*%[')
    if not startPos then
        return array
    end

    local arrayContent = extractCompleteArray(text, startPos)
    if not arrayContent then
        return array
    end

    local numbers = {}
    for number in arrayContent:gmatch("([%d%.%-]+)") do
        table.insert(numbers, tonumber(number))
    end

    for i = 1, #numbers - 1, 2 do
        table.insert(array, { numbers[i], numbers[i+1] })
    end

    return array
end

local function parseSpecValue(text, key)
    local pattern = '"' .. key .. '"%s*:%s*"(.-)"'
    local value = text:match(pattern)
    return value or ""
end

local function lerp(a, b, t)
    return a + (b - a) * t
end

local function getInterpolatedFromCurve(rpm, curve)
    if rpm <= curve[1][1] then return curve[1][2] end
    if rpm >= curve[#curve][1] then return curve[#curve][2] end
    for i = 1, #curve - 1 do
        local rpmA, valueA = curve[i][1], curve[i][2]
        local rpmB, valueB = curve[i+1][1], curve[i+1][2]
        if rpm >= rpmA and rpm <= rpmB then
            local t = (rpm - rpmA) / (rpmB - rpmA)
            return lerp(valueA, valueB, t)
        end
    end
    return 0
end

local carName = ac.getCarID(0)
local carJsonPath = basePath .. carName .. "/ui/ui_car.json"

print("founded folder:", carName)

local torqueCurve, powerCurve, bhp, maxTorque = {}, {}, 0, 0

local function getCurveMaximum(curve)
    local maxVal = 0
    for _, point in ipairs(curve) do
        if point[2] > maxVal then
            maxVal = point[2]
        end
    end
    return maxVal
end

if carJsonPath then
    local jsonContent = readFile(carJsonPath)
    if jsonContent then
        torqueCurve = parseCurveArray(jsonContent, "torqueCurve")
        powerCurve = parseCurveArray(jsonContent, "powerCurve")

        local bhp_raw = parseSpecValue(jsonContent, "bhp")
        local torque_raw = parseSpecValue(jsonContent, "torque")

        bhp = tonumber(bhp_raw:match("(%d+)")) or 0
        maxTorque = tonumber(torque_raw:match("(%d+)")) or 0

        if bhp == 0 and #powerCurve > 0 then
            bhp = math.floor(getCurveMaximum(powerCurve) + 0.5)
        end

        if maxTorque == 0 and #torqueCurve > 0 then
            maxTorque = math.floor(getCurveMaximum(torqueCurve) + 0.5)
        end


        print("Max Torque (specs): " .. tostring(maxTorque) .. " Nm")
        print("Max Power (specs): " .. tostring(bhp) .. " PS")
    end
end

local currentTorque = 0
local currentPower = 0
local smoothedRpm = 0

function TorquePower:new(o)
    o = o or Extension:new(o)
    setmetatable(o, self)
    self.__index = self
    return o
end

function TorquePower:update(dt, customData)
    local carState = ac.getCar(0)
    local currentRpm = math.floor(carState.rpm)
    smoothedRpm = smoothedRpm * 0.85 + currentRpm * 0.15

    if #torqueCurve > 0 and #powerCurve > 0 then
        currentTorque = getInterpolatedFromCurve(smoothedRpm, torqueCurve)
        currentPower = getInterpolatedFromCurve(smoothedRpm, powerCurve)

        currentTorque = math.floor(currentTorque / 10 + 0.5) * 10
        currentPower = math.floor(currentPower / 10 + 0.5) * 10
    end

    customData.currentpower = currentPower
    customData.currenttorque = currentTorque
    customData.bhp = bhp
    customData.torque = maxTorque

end

return TorquePower
