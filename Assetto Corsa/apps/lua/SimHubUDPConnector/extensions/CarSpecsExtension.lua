CarSpecsExtension = {}

local initialized = false
local specJSON

local function capitalizeFirst(str)
  return str:sub(1, 1):upper() .. str:sub(2):lower()
end

local function initializeSpecs()
  local specFileName = ac.getFolder(ac.FolderID.ContentCars) .. "\\" ..  ac.getCarID(0) .. "\\ui\\ui_car.json"
  local specFile = io.load(specFileName)
  specJSON = JSON.parse(specFile)
  initialized = true
end

function CarSpecsExtension:update(dt, customData)
  if not initialized then
    initializeSpecs()
    if not specJSON then return end
  end

  for key, prop in pairs(specJSON.specs) do
    customData["CarSpecsExt_" .. capitalizeFirst(key)] = prop
  end
end

return CarSpecsExtension
