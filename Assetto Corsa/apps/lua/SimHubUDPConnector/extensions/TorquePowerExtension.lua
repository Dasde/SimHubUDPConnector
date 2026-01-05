TorquePower = {}

local powerLut = nil
local maxPowerHP = 0
local maxTorque = 0
local initialized = false

local function initializePowerLUT()
  local car = ac.getCar(0)
  powerLut = ac.DataLUT11.carData(car.index, "power.lut")

  for rpm = 0, 15000, 50 do
    local torque = powerLut:get(rpm)
    local power = torque * rpm / 9549

    if torque > maxTorque then maxTorque = torque end
    if power > maxPowerHP then maxPowerHP = power end
  end

  maxTorque = math.floor(maxTorque / 5 + 0.5) * 5
  maxPowerHP = math.floor(maxPowerHP / 5 + 0.5) * 5

  initialized = true
end

function TorquePower:update(dt, customData)
  if not initialized then
    initializePowerLUT()
    if not powerLut then return end
  end

  local car = ac.getCar(0)
  local rpm = car.rpm or 0

  local torque = powerLut:get(rpm)
  local power = torque * rpm / 9549

  torque = math.floor(torque / 5 + 0.5) * 5
  power = math.floor(power / 5 + 0.5) * 5

  customData.TorquePowerExt_currentTorqueNm = torque
  customData.TorquePowerExt_currentPowerHP = power
  customData.TorquePowerExt_torqueNM = maxTorque
  customData.TorquePowerExt_maxPowerHP = maxPowerHP
end

return TorquePower
