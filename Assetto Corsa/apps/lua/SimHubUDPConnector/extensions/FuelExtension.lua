FuelExtension = {}

local carState = ac.getCar(0)
local sim = ac.getSim()

function FuelExtension:update(dt, customData)
    customData.FuelExt_fuel = carState.fuel
    customData.FuelExt_fuelPerLap = carState.fuelPerLap
    customData.FuelExt_maxFuel = carState.maxFuel
    customData.FuelExt_fuelMap = carState.fuelMap
    customData.FuelExt_fuelMaps = carState.fuelMaps
    customData.FuelExt_fuelConsumptionRate = sim.fuelConsumptionRate
    customData.FuelExt_fuelRemainingLaps = carState.fuelPerLap>0 and carState.fuel / carState.fuelPerLap or 0
    for i, c in ac.iterateCars.leaderboard() do
        customData["FuelExt_pos_" ..i.."_fuel"] = c.fuel
        customData["FuelExt_pos_" ..i.."_fuelPerLap"] = c.fuelPerLap
        customData["FuelExt_pos_" ..i.."_maxFuel"] = c.maxFuel
        customData["FuelExt_pos_" ..i.."_fuelMap"] = c.fuelMap
        customData["FuelExt_pos_" ..i.."_fuelMaps"] = c.fuelMaps
        customData["FuelExt_pos_" ..i.."_fuelRemainingLaps"] = c.fuelPerLap>0 and c.fuel / c.fuelPerLap or 0
    end
end

return FuelExtension