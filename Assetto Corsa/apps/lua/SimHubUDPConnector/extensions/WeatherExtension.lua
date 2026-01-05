WeatherExtension = {}

-- local carState = ac.getCar(0)
local sim = ac.getSim()

local function getWeatherTypeName(weatherType)
   if weatherType == 0 then
      return "Light Thunderstorm"
    elseif weatherType == 1 then
      return "Thunderstorm"
    elseif weatherType == 2 then
      return "Heavy Thunderstorm"
    elseif weatherType == 3 then
        return "Light Drizzle"
    elseif weatherType == 4 then
        return "Drizzle"
    elseif weatherType == 5 then
        return "Heavy Drizzle"
    elseif weatherType == 6 then
        return "Light Rain" 
    elseif weatherType == 7 then
        return "Rain"
    elseif weatherType == 8 then
        return "Heavy Rain"
    elseif weatherType == 9 then
        return "Light Snow"
    elseif weatherType == 10 then
        return "Snow"
    elseif weatherType == 11 then
        return "Heavy Snow"
    elseif weatherType == 12 then
        return "Light Sleet"
    elseif weatherType == 13 then
        return "Sleet"
    elseif weatherType == 14 then
        return "Heavy Sleet"
    elseif weatherType == 15 then
        return "Clear"
    elseif weatherType == 16 then
        return "Few Clouds"
    elseif weatherType == 17 then
        return "Scattered Clouds"
    elseif weatherType == 18 then
        return "Broken Clouds"
    elseif weatherType == 19 then
        return "Overcast Clouds"
    elseif weatherType == 20 then
        return "Fog"
    elseif weatherType == 21 then
        return "Mist"
    elseif weatherType == 22 then
        return "Smoke"
    elseif weatherType == 23 then
        return "Haze"
    elseif weatherType == 24 then
        return "Sand"
    elseif weatherType == 25 then
        return "Dust"
    elseif weatherType == 26 then
        return "Squalls"
    elseif weatherType == 27 then
        return "Tornado"
    elseif weatherType == 28 then
        return "Hurricane"
    elseif weatherType == 29 then
        return "Cold"
    elseif weatherType == 30 then
        return "Hot"
    elseif weatherType == 31 then
        return "Windy"
    elseif weatherType == 32 then
        return "Hail"
    else
        return "Unknown Weather"
    end
end

local function tolowerAndnderscore(str)
    -- split string by capitalization and spaces
    str = str:gsub("(%l)(%u)", "%1_%2") -- add underscore before uppercase letters      
    return str:lower()
end

function WeatherExtension:update(dt, customData)
    customData.WeatherExt_AmbientTemperature = sim.ambientTemperature
    customData.WeatherExt_RainIntensity = sim.rainIntensity
    customData.WeatherExt_RainWetness = sim.rainWetness
    customData.WeatherExt_WeatherType = sim.weatherType
    customData.WeatherExt_WeatherUpcomingType = sim.weatherConditions.upcomingType
    customData.WeatherExt_WeatherTypeName = getWeatherTypeName(sim.weatherType)
    customData.WeatherExt_WeatherUpcomingTypeName = getWeatherTypeName(sim.weatherConditions.upcomingType)
    customData.WeatherExt_WeatherIcon = 'https://acstuff.ru/images/icons_24/' .. tolowerAndnderscore(ui.weatherIcon(sim.weatherType)) .. '.png'
    customData.WeatherExt_WindDirectionDeg = sim.windDirectionDeg
    customData.WeatherExt_WindSpeedKmh = sim.windSpeedKmh
end

return WeatherExtension