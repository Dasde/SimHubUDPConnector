local connection = {}
-- don't do anything anymore, will be removed soon.
-- local DBZKey = ac.getCarID(0) .. "_dbz_cars"
-- local DBZSharedData = {
--   ac.StructItem.key(DBZKey .. "_" .. 0),
--   Connected = ac.StructItem.boolean(),
--   AntiLagEnabled = ac.StructItem.boolean(),
--   AntiLagActive = ac.StructItem.boolean(),
--   ALSMode = ac.StructItem.int8(),
-- }

-- DBZConnection = ac.connect(DBZSharedData, false, ac.SharedNamespace.Shared)

-- local antilagINI = ac.INIConfig.carData(ac.getCar(0).index, "antilag.ini")
-- local count = 0
-- local modeNames = {
-- }
-- while (antilagINI:get("MODE_" .. count + 1, 'RPM_MIN', 0) > 0) do
--     count = count + 1
--     modeNames[count] = antilagINI:get("MODE_" .. count, 'NAME', count == 1 and "SOFT" or
--         (count == 2 and "MEDIUM" or "HARD"))
-- end

function connection:carScript(customData)
    -- addCarData(DBZConnection, DBZSharedData, 'DBZ_', customData)
    -- customData.DBZ_ALSModesCount = #modeNames
    -- customData.DBZ_ALSModeName = modeNames[DBZConnection.ALSMode]
end

return connection
