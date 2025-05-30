local connection = {}
local carId = ac.getCarID(0)
local ECU_Cadenza_Struct = {
    ac.StructItem.key(carId .. "_ecu_" .. 0),
    connected = ac.StructItem.boolean(),
    collisionDepth = ac.StructItem.float(),
    collidedWith = ac.StructItem.int16(),
    displayPage = ac.StructItem.int16(),
    requestedEngineRPM = ac.StructItem.float(),
    throttleBodyPosition = ac.StructItem.float(),
    requestedThrottleBodyPosition = ac.StructItem.float(),
    deploymentStrat = ac.StructItem.float(),
    diffPreset = ac.StructItem.int16(),
    pedalMap = ac.StructItem.int16(),
    torqueMap = ac.StructItem.int16(),
    torqueSplit = ac.StructItem.int16(),
    fuelUsedLastLap = ac.StructItem.float(),
    kersTorqueLevel = ac.StructItem.float(),
    kersFrontMotorActive = ac.StructItem.boolean(),
    kersFrontMotorPerc = ac.StructItem.float(),
    kersInput = ac.StructItem.float(),
    kersMinSpeedKmh = ac.StructItem.float(),
    kersMaxSpeedKmh = ac.StructItem.float(),
    stintMaxEnergyMJ = ac.StructItem.float(),
    stintEnergyMJ = ac.StructItem.float(),
    stintEnergyMJLap = ac.StructItem.float(),
    stintEstimatedLapsRemaining = ac.StructItem.float(),
    stintEnergyLastLap = ac.StructItem.float(),
    stintTargetEnergyGap = ac.StructItem.float(),
    stintTargetEnergyPerLap = ac.StructItem.float(),
    stintLapsCompleted = ac.StructItem.float(),
    currentEnergyMJPerLap = ac.StructItem.float(),
    virtualEnergyTankMJ = ac.StructItem.float(),
    powerIllegal = ac.StructItem.float(),
    brakeBiasCoarse = ac.StructItem.float(),
    brakeBiasFine = ac.StructItem.float(),
    brakeBiasLive = ac.StructItem.float(),
    brakeBiasPeak = ac.StructItem.float(),
    brakeMigration = ac.StructItem.float(),
    mgukRecovery = ac.StructItem.float(),
    kersRegenLevel = ac.StructItem.float(),
    kersDeliveryLevel = ac.StructItem.float(),
    brakeLevel = ac.StructItem.float(),
    tcSlipSetting = ac.StructItem.int16(),
    tcCutSetting = ac.StructItem.int16(),
    tcCut = ac.StructItem.float(),
    tcLatSetting = ac.StructItem.int16(),
    tcLongSetting = ac.StructItem.int16(),
    tcTargetSlip = ac.StructItem.float(),
    engineBrakeSetting = ac.StructItem.int16(),
    antirollBarFrontPosition = ac.StructItem.int16(),
    antirollBarRearPosition = ac.StructItem.int16(),
    isTCActive = ac.StructItem.boolean(),
    isAntistallActive = ac.StructItem.boolean(),
    isEngineStalled = ac.StructItem.boolean(),
    isEngineStarted = ac.StructItem.boolean(),
    isEngineRunning = ac.StructItem.boolean(),
    isStarterCranking = ac.StructItem.boolean(),
    isIgnitionOn = ac.StructItem.boolean(),
    isElectronicsBooted = ac.StructItem.boolean(),
    isKersOvertakeActive = ac.StructItem.boolean(),
    driverTargetStintLaps = ac.StructItem.int16(),
    driverTargetLapTime = ac.StructItem.int32(),
    isPitSpeedLimiterActive = ac.StructItem.boolean(),
    bumpPrimeEngineRequest = ac.StructItem.boolean(),
}
local ECU_Cadenza = ac.connect(ECU_Cadenza_Struct, true, ac.SharedNamespace.CarScript)

function connection:carScript(customData)
    addCarData(ECU_Cadenza, ECU_Cadenza_Struct, 'ECU_', customData)
end

return connection