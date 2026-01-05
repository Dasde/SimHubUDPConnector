LegacyDataExtension = {}

local carState = ac.getCar(0)
local sim = ac.getSim()

function LegacyDataExtension:update(dt, customData)
    customData.AmbientTemperature = sim.ambientTemperature
    customData.Autoclutch = carState.autoClutch
    customData.Brake = carState.brake
    customData.CarDirection = carState.compass
    customData.CarForceFeedback = carState.ffbMultiplier * 100
    customData.CarName = ac.getCarName(0)
    customData.Clutch = (carState.autoClutch) and (carState.clutch) or (1 - carState.clutch)

    customData.DifferentialPreload = carState.differentialPreload
    customData.DifferenialCoast = carState.differentialCoast
    customData.DifferentialPower = carState.differentialPower
    -- drift part
    customData.DriftPoints = carState.driftPoints
    customData.DriftComboCounter = carState.driftComboCounter
    customData.DriftInstantPoints = carState.driftInstantPoints
    customData.IsDriftBonusOn = carState.isDriftBonusOn
    customData.IsDriftValid = carState.isDriftValid
    -- end
    customData.DistanceDrivenTotalKm = carState.distanceDrivenTotalKm
    customData.DistanceDrivenSessionKm = carState.distanceDrivenSessionKm
    customData.ExtraA = carState.extraA
    customData.ExtraB = carState.extraB
    customData.ExtraC = carState.extraC
    customData.ExtraD = carState.extraD
    customData.ExtraE = carState.extraE
    customData.ExtraF = carState.extraF
    customData.ExtraG = carState.extraG
    customData.FPS = sim.fps
    customData.FuelMap = carState.fuelMap
    customData.Handbrake = carState.handbrake
    customData.HazardLights = carState.hazardLights
    customData.HeadlightsActive = carState.headlightsActive
    customData.HighBeam = not carState.lowBeams
    customData.IngameHours = sim.timeHours
    customData.IngameMinutes = sim.timeMinutes
    customData.IsInPitlane = carState.isInPitlane
    customData.IsInPit	= carState.isInPit
    customData.KERSCharge = carState.kersCharge
    customData.KERSCharging = carState.kersCharging
    customData.KERSCurrentKJ = carState.kersCurrentKJ
    customData.KERSLoad = carState.kersLoad
    customData.KERSMaxKJ = carState.kersMaxKJ
    customData.KERSPresent = carState.kersPresent
    customData.LightOptions = carState.hasLowBeams
    customData.LimiterOn = carState.manualPitsSpeedLimiterEnabled
    customData.LimiterSpeed = carState.speedLimiter
    customData.MGUHChargingBatteries = carState.mguhChargingBatteries
    customData.MGUKDelivery = carState.mgukDelivery
    customData.MGUKDeliveryCount = carState.mgukDeliveryCount
    customData.MGUKDeliveryName = ac.getMGUKDeliveryName(0,carState.mgukDelivery)
    customData.MGUKRecovery = carState.mgukRecovery -- 0 to 10 (10 for 100%)		
    customData.OilPressure = carState.oilPressure
    customData.OilTemperature = carState.oilTemperature
    customData.P2PStatus = carState.p2pStatus
    customData.P2PActivations = carState.p2pActivations
    customData.Steer = carState.steer
    customData.SteerLock = carState.steerLock
    customData.TC2 = carState.tractionControl2
    customData.Throttle = carState.gas
    customData.TrackName = ac.getTrackName()
    customData.Turn = ac.getTrackSectorName(ac.worldCoordinateToTrackProgress(carState.position))
    customData.TurningLeftLights = carState.turningLeftLights
    customData.TurningRightLights = carState.turningRightLights
    customData.IsVirtualMirrorActive = sim.isVirtualMirrorActive
    customData.IsVirtualMirrorForced = sim.isVirtualMirrorForced
    customData.WaterTemperature = carState.waterTemperature

    customData.WindDirectionDeg = sim.windDirectionDeg
    customData.WindSpeedKmh = sim.windSpeedKmh
    customData.WiperModes = carState.wiperModes
    customData.WiperMode = carState.wiperMode
    customData.WiperSelectedMode = carState.wiperSelectedMode
    customData.WiperSpeed = carState.wiperSpeed
    customData.WiperProgress = carState.wiperProgress

end

return LegacyDataExtension