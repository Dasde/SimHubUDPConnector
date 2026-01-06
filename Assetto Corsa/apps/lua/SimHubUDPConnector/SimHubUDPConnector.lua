local AppSettings = ac.storage {
	log = false,
	autoUpdate = true
}

local UDPSettings = table.chain(
	{ host = '127.0.0.1', port = 20777 },
	stringify.tryParse(ac.storage.UDPSettings, {}))
---@diagnostic disable-next-line: inject-field
ac.storage.UDPSettings = stringify(UDPSettings)

local ExtensionsSettings
local ExtensionsSettingsLayout = {
	LegacyDataExtension = true,
	CollisionsExtension = true,
	RoadRumbleExtension = true,
	OnlineOvertakeExtension = false,
	WheelExtension = false,
	TyreOptimalTempExtension = false,
	LeaderBoardExtension = false,
}
local obsoleteExtensions = {"TyreOptimalTempExtension", "LeaderBoardExtension"}

local manifest = ac.INIConfig.load(ac.dirname() .. '/manifest.ini', ac.INIFormat.Extended)
local appVersion = manifest:get('ABOUT', 'VERSION', "0.0.0")
local socket = require('shared/socket')
local udp = socket.udp()
local debugOn = AppSettings.log and type(AppSettings.log) == "boolean" or false ---@type boolean
local carState = ac.getCar(0)
local cspVersion = ac.getPatchVersion()
local customData = {CSPVersion = cspVersion}
local customFastData = {}
local lastFastData = {}
local carScript = nil
local detectedExtensions = {} ---@type string[]
local loadedExtensions = {}
local loadedHightPriorityExtensions = {}
local repoVersion = "0.0.0"
local updatingApp = false
local highPriorityExtensions = {"RoadRumbleExtension", "CollisionsExtension"}
local jsonBuffer = {}
local ROUNDING = 3
local MULT = 10 ^ ROUNDING
local benchDone = false
local slowUpdateTimer = 0 local slowUpdateRate = 1 / 60 -- 60 Hz

local function encodeValue(v)
	if v == nil then jsonBuffer[#jsonBuffer+1] = "null" return end
    local tv = type(v)
    if tv == "number" then
		if v ~= v or v == math.huge or v == -math.huge then jsonBuffer[#jsonBuffer+1] = "null" return end
		if v % 1 == 0 then jsonBuffer[#jsonBuffer+1] = tostring(v) return end
		v = math.floor(v * MULT + 0.5) / MULT
        jsonBuffer[#jsonBuffer+1] = tostring(v)
    elseif tv == "boolean" then
        jsonBuffer[#jsonBuffer+1] = v and "true" or "false"
    elseif tv == "string" then
        jsonBuffer[#jsonBuffer+1] = '"'
        jsonBuffer[#jsonBuffer+1] = v
        jsonBuffer[#jsonBuffer+1] = '"'
    elseif tv == "table" then
        -- assume array
        jsonBuffer[#jsonBuffer+1] = "["
        for i = 1, #v do
            encodeValue(v[i])
            jsonBuffer[#jsonBuffer+1] = ","
        end
        if v[1] then
            jsonBuffer[#jsonBuffer] = "]"
        else
            jsonBuffer[#jsonBuffer+1] = "]"
        end
    else
        -- fallback
        local s = tostring(v)
		jsonBuffer[#jsonBuffer+1] = '"'
		jsonBuffer[#jsonBuffer+1] = s
		jsonBuffer[#jsonBuffer+1] = '"'
    end
end

local function ultraJSON(t)
    table.clear(jsonBuffer)
    jsonBuffer[#jsonBuffer+1] = "{"
    for k, v in pairs(t) do
        jsonBuffer[#jsonBuffer+1] = '"'
        jsonBuffer[#jsonBuffer+1] = k
        jsonBuffer[#jsonBuffer+1] = '":'
        encodeValue(v)
        jsonBuffer[#jsonBuffer+1] = ","
    end
    if jsonBuffer[#jsonBuffer] == "," then
        jsonBuffer[#jsonBuffer] = "}"
    else
        jsonBuffer[#jsonBuffer+1] = "}"
    end
    return table.concat(jsonBuffer)
end


local function bench(label, fn)
    local t0 = os.clock()
    for _ = 1, 20000 do
        fn()
    end
    local t1 = os.clock()
    print(label .. " : " .. (t1 - t0))
end

---Loads a lua script.
---@param scriptName string
---@param scriptFolder string
---@param silent boolean?
---@return unknown ret the loaded script or false.
local function loadLuaScript(scriptName, scriptFolder, silent)
	local ret
	local scriptPath = ac.dirname() .. "/" .. scriptFolder .. "/" .. scriptName
	if io.fileExists(scriptPath .. ".lua") then
		try(
			function() --try
				ret = require(scriptFolder:replace("/", ".") .. "." .. scriptName)
			end,
			function(err) --catch
				print("script " .. scriptName .. " ERROR : " .. err)
			end
		)
	else
		if not silent then
			print("script not found : " .. scriptName .. ".lua")
		end
	end
	return ret
end

---Try to load a car script based on a filter
---@param scriptName string
---@param carId string
---@param silent boolean
---@return unknown ret
local function loadLuaCarFilterScript(scriptName, carId, silent)
	local filtersRelativePath = "cars/filters" .. "/"
	local filtersPath = ac.dirname() .. "/" .. filtersRelativePath
	local connectionFolder = nil
	local ret = io.scanDir(filtersPath, function(fileName, fileAttributes, callbackData)
		if carId:startsWith(fileName) then
			connectionFolder = filtersRelativePath .. fileName
			---@diagnostic disable-next-line: redundant-return-value
			return loadLuaScript(scriptName, connectionFolder, false)
		end
	end)
	return ret
end

local function tryLoadCarConnection()
	local carId = ac.getCarID(0)
	local carFolder = "cars/" .. carId
	carScript = loadLuaScript("connection", carFolder, true)
	if (not carScript) then
	---@diagnostic disable-next-line: param-type-mismatch
		carScript = loadLuaCarFilterScript("connection", carId, true)
	end
end

---Check if a list contains a value.
---@param list table?
---@param value string
---@return boolean
local function contains(list, value)
	if list == nil then return false end
	for _, v in ipairs(list) do
		if v == value then
			return true
		end
	end
	return false
end

local function loadExtensions()
	-- Scan for new extensions.
	io.scanDir(ac.dirname() .. "/extensions", function(fileName, fileAttributes, callbackData)
		if fileName:endsWith("Extension.lua") then
			local extName = fileName:replace(".lua", "")
			if extName ~= "Extension" and extName ~= "SampleUserExtension" and not table.contains(obsoleteExtensions, extName) then
				if ExtensionsSettingsLayout[extName] == nil then
					ExtensionsSettingsLayout[extName] = false
				end
				detectedExtensions[#detectedExtensions + 1] = extName
			end
		end
	end)
	ExtensionsSettings = ac.storage(ExtensionsSettingsLayout)
	local useTyreExt = false
	if ExtensionsSettings["TyreOptimalTempExtension"] then
		useTyreExt = true
		ExtensionsSettings["TyreOptimalTempExtension"] = false
	end
	if useTyreExt then
		ExtensionsSettings["TyreExtension"] = true
	end
	table.sort(detectedExtensions)
	for _, extName in pairs(detectedExtensions) do
		if ExtensionsSettings[extName] then
			if table.contains(highPriorityExtensions, extName) then
				loadedHightPriorityExtensions[extName] = loadLuaScript(extName, "extensions")
			else
				loadedExtensions[extName] = loadLuaScript(extName, "extensions")
			end
		end
	end
end

---Display all the properies in the lua debug app.
---@param data table list of properties to print. Usually that's customData the object sent to simhub.
local function debugData(data)
	for k, v in pairs(data) do
		ac.debug(k, v)
	end
end

---Write a file on disk
---@param file string relative path of the file
---@param content string content of the file
---@param folder string destinatin folder
local function writeFile(file, content, folder)
	local filename = folder .. "\\" .. file -- :match("/(.*)")
	filename = filename:replace("/", "\\")
	if not io.dirExists(filename) then
		io.createFileDir(filename)
	end
	-- print(filename)
	if io.save(filename, content) then
		-- print(filename .. " successfully written to disk")
	else
		print("Error writing " .. filename)
	end
end

---Update the app to a specific version
---@param version string
local function updateApp(version)
	updatingApp = true
	---@diagnostic disable-next-line: inject-field
	ac.storage.updateToVersion = version
	local urlRelease = "https://github.com/Dasde/SimHubUDPConnector/releases/download/v" ..
		version .. "/SimHubUDPConnector.zip"
	web.get(urlRelease, function(errRelease, responseRelease)
		if errRelease then
			updatingApp = false
			print(errRelease)
			error(errRelease)
		end
		local acFolder = ac.getFolder(ac.FolderID.Root)
		local appFile, appContent
		for _, file in ipairs(io.scanZip(responseRelease.body)) do
			local content = io.loadFromZip(responseRelease.body, file)
			if content then
				if (file:endsWith("SimHubUDPConnector.lua")) then
					appFile = file
					appContent = content
				else
					writeFile(file, content, acFolder)
				end
			end
		end
		if appContent then
			writeFile(appFile, appContent, acFolder)
		end
	end)
	updatingApp = false
end

---Get the latest version from the repo and update if asked.
---@param update boolean
---@param force? boolean
local function getLatestVersion(update, force)
	local urlManifest =
	"https://raw.githubusercontent.com/Dasde/SimHubUDPConnector/refs/heads/main/Assetto%20Corsa/apps/lua/SimHubUDPConnector/manifest.ini"
	web.get(urlManifest, function(err, response)
		if err then print(error(err)) end
		local repoManifest = response.body
		if not repoManifest then return print('Missing manifest on the repo.') end
		repoVersion = ac.INIConfig.parse(repoManifest, ac.INIFormat.Extended):get('ABOUT', 'VERSION', "0.0.0")
		if (update) then
			if repoVersion:versionCompare(appVersion) <= 0 then
				print("no update. versions : repo " .. repoVersion .. " app " .. appVersion)
				if (not force) then return end
			end
			updateApp(repoVersion)
		end
	end)
end

local function checkForUpdate()
	if ac.storage.updateToVersion and ac.storage.updateToVersion:versionCompare(appVersion) == 0 then
		print("App successfully updated to version " .. appVersion)
		---@diagnostic disable-next-line: inject-field
		ac.storage.updateToVersion = "0.0.0"
	end
	getLatestVersion(AppSettings.autoUpdate)
end

udp:settimeout(0)
udp:setpeername(UDPSettings.host, UDPSettings.port)
checkForUpdate()
loadExtensions()
tryLoadCarConnection()

---Add the car script data to a list.
---@param connection any ac.connect connection to the car script.
---@param struct table layout/structure used for the ac.connect.
---@param prefix string a prefix to add to the properties name.
---@param to table list to add the properties to. Usually that's customData the object sent to simhub.
---@param excludedFields table? @Optional a list of fields to exclude from the exported list.
function addCarData(connection, struct, prefix, to, excludedFields)
	local propName
	for k, _ in pairs(struct) do
		if type(k) == "string" and not contains(excludedFields, k) then
			propName = prefix .. k:sub(1, 1):upper() .. k:sub(2)
			to[propName] = connection[k]
		end
	end
end

---Add a property to a list.
---@param prefix string a prefix to add to the properties name.
---@param obj table object that holds the field.
---@param fieldName string name of the field to add as a property.
---@param to any
function addProp(prefix, obj, fieldName, to)
	local propName = prefix .. fieldName:sub(1, 1):upper() .. fieldName:sub(2)
	to[propName] = obj[fieldName]
end

local function fastDataChanged(a, b)
    for k, v in pairs(a) do
        if b[k] ~= v then return true end
    end
    for k, v in pairs(b) do
        if a[k] ~= v then return true end
    end
    return false
end

local function disposeExtension(extension)
	if extension and extension.dispose then
		try(function ()
			extension:dispose()
		end)
	end
end

local function drawExtensionSettingsTab(extension)
	if extension and extension.drawSettingsTab then
		try(function ()
			extension:drawSettingsTab()
		end, function (err)
			print("Extension settings tab generated an error : " .. err)
		end)
	end
end

function script.update(dt)
	slowUpdateTimer = slowUpdateTimer + dt
	if slowUpdateTimer < slowUpdateRate then return end
	slowUpdateTimer = 0
	if (carState == nil) then return end
	table.clear(customData)
	customData.CSPVersion = cspVersion
	for extName, ext in pairs(loadedExtensions) do
		try(function()
			ext:update(dt, customData)
		end, function(err)
			print("Extension " .. extName .. " generated an error : " .. err)
		end)
	end

	if (carScript ~= nil) then
		try(function()
			carScript:carScript(customData)
		end, function(err)
			print("Car script for " .. ac.getCarID(0) .. " generated an error : " .. err)
		end)
	end
	local jsonData = ultraJSON(customData)

	-- if not benchDone then
	-- 	bench("JSON.stringify", function()
	-- 		ac.debug("stringify", JSON.stringify(customData))
	-- 	end)
	
	-- 	bench("ultraJSON", function()
	-- 		ac.debug("ultraJSON", ultraJSON(customData))
	-- 	end)
	-- 	benchDone = true
	-- end
	udp:send(jsonData)

	-- for debug only
	if debugOn then
		debugData(customData)
	end
end

function script.updateHighPriority(dt)
	table.clear(customFastData)
	for extName, ext in pairs(loadedHightPriorityExtensions) do
		try(function()
			ext:update(dt, customFastData)
		end, function(err)
			print("High Prioriy Extension " .. extName .. " generated an error : " .. err)
		end)
	end
	if fastDataChanged(customFastData, lastFastData) then
		udp:send(ultraJSON(customFastData))
		lastFastData = table.clone(customFastData)
		if debugOn then
			debugData(customFastData)
		end
	end
end

function script.onStop()
	udp:close()
end

function script.windowMain(dt)
	if updatingApp then
		ui.text("Updating app, please wait...")
		ui.newLine()
		ui.icon(ui.Icons.LoadingSpinner, 160)
		ui.newLine()
		return
	end
	ui.tabBar('simhubUDPConnectorTabBarID', function()
		ui.tabItem('Extensions', function()
			for _, extName in pairs(detectedExtensions) do
				local value = ExtensionsSettings[extName]
				if ui.checkbox(extName, value) then
					if debugOn then
						ac.clearDebug()
					end
					customData = {}
					value = not value
					ExtensionsSettings[extName] = value
					if value then
						if table.contains(highPriorityExtensions, extName) then
							loadedHightPriorityExtensions[extName] = loadLuaScript(extName, "extensions")
						else
							loadedExtensions[extName] = loadLuaScript(extName, "extensions")
						end
					else
						if table.contains(highPriorityExtensions, extName) then
							disposeExtension(loadedHightPriorityExtensions[extName])
							loadedHightPriorityExtensions[extName] = nil
						else
							disposeExtension(loadedExtensions[extName])
							loadedExtensions[extName] = nil
						end
						package.loaded["extensions." .. extName] = nil
					end
				end
			end
		end)
		ui.tabItem('Settings', function()
			if ui.checkbox("Debug", debugOn) then
				if debugOn then
					ac.clearDebug()
				end
				debugOn = not debugOn
				AppSettings.log = debugOn
			end
			ui.text("Version " .. appVersion)
			if repoVersion:versionCompare(appVersion) > 0 then
				if not AppSettings.autoUpdate then
					ui.textColored("A new version (" .. repoVersion .. ") is available", rgbm.colors.red)
					if ui.button("Update...") then
						updateApp(repoVersion)
					end
				end
			else
				ui.textColored("The latest version is installed.", rgbm.colors.green)
				if ui.button("Reset app..", ui.ButtonFlags.Confirm) then
					getLatestVersion(true, true)
				end
			end
			if ui.checkbox("Auto-Update", AppSettings.autoUpdate) then
				AppSettings.autoUpdate = not AppSettings.autoUpdate
			end
			ui.text("UDP Settings")
			local UDPSettingsChanged = false
			local hostChanged
			UDPSettings.host, hostChanged = ui.inputText("host", UDPSettings.host,
				ui.InputTextFlags.CharsDecimal and ui.InputTextFlags.CharsNoBlank)
			if hostChanged then
				UDPSettingsChanged = true
			end
			local portChanged, udpPort
			udpPort, portChanged = ui.inputText("port", tostring(UDPSettings.port),
				ui.InputTextFlags.CharsDecimal and ui.InputTextFlags.CharsNoBlank)
			if portChanged then
				ac.debug("port : ", udpPort)
				UDPSettings.port = tonumber(udpPort)
				UDPSettingsChanged = true
			end
			if UDPSettingsChanged then
				---@diagnostic disable-next-line: inject-field
				ac.storage.UDPSettings = stringify(UDPSettings)
				if ui.button("Restart UDP connection") then
					udp:close()
					udp:setpeername(UDPSettings.host, UDPSettings.port)
				end
			end
		end)
		for _, ext in pairs(loadedExtensions) do
			drawExtensionSettingsTab(ext)
		end
	end)
end
