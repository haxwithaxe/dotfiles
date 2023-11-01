#!/usr/bin/lua

-- load the http socket module
http = require("socket.http")
json = require("json")

function string.tohex(str)
    return (str:gsub('.', function (c)
        return string.format('\\x%02X', string.byte(c))
    end))
end

local lib = require('lib')

-- Must log to stderr to prevent i3bar from choking on log messages breaking the JSON stream
local log = lib.log:new({level = lib.log.ERROR})

API_URL = "http://api.openweathermap.org/data/2.5/weather?"

-- Let lua handle spelling mistakes
METRIC = 'metric'
IMPERIAL = 'imperial'

-- API icon IDs mapped to unicode weather symbols
icons = {
  ["01"] = "☀",
  ["02"] = "🌤",
  ["03"] = "🌥",
  ["04"] = "☁",
  ["09"] = "🌧",
  ["10"] = "🌦",
  ["11"] = "🌩",
  ["13"] = "🌨",
  ["50"] = "🌫",
}


local config = {
    zipcode = '00000',
    -- "metric" or "imperial"
    units = METRIC,
    -- Get an open weather map api key: http://openweathermap.org/appid
    apikey = "",
    cache_filename = 'weather.json',
    _api_url = API_URL
}


local cache = {

  read = function()
      local cache_file = io.open(config.cache_filename, "r+")
      if cache_file ~= nil then
        --debug('before cache.read decode')
        raw = cache_file:read()
        if not raw then return nil end
        data = json.decode(raw)
        log:debug('after cache.read decode\n')
        cache_file:close()
        return data
      else
        return nil
      end
  end,

  write = function(data)
      local cache_file = io.open(config.cache_filename, "w")
      cache_file:write(json.encode(data))
      cache_file:close()
  end

}


local download_weather = function()
      url = ("%szip=%s&units=%s&APPID=%s"):format(config._api_url, config.zipcode, config.units, config.apikey)
      log:debug('download_weather: url = %s', tostring(url))
      weather_data, status, _ = http.request(url)
      if type(status) == 'string' then
           log:info('status: %s', status)
	   return nil
      end
      if status < 200 or status >= 300 then
          log:err('Failed to get weather data. Response status: %s, response message: %s', status, json.decode(weather_data).message)
          return nil
      end
      if weather_data then
          log:debug('download_weather: before weather data decode')
          response = json.decode(weather_data)
          log:debug('download_weather: after weather data decode')
          if response['cod'] == 401 then
            log:err('OpenWeatherMap API: code = %d, message = %s', response['cod'], response['message'])
            return nil
          end
          return response
      end
end


-- Return the weather as a table.
local get = function()
    wx = {
      temp = 'U',
      conditions = 'U',
      icon = ':(',
      units = 'F'
    }
    data = cache.read()
    if data and data.timestamp then
      timepassed = os.difftime(os.date("!%Y%m%d%H%M%S"), data.timestamp)
    else
      timepassed = 6000
    end

    if timepassed < 3600 then
      response = data
    else
      response = download_weather()
    end

    if not response or not response.main then
        --debug(('Bad response: %s, %s'):format(response.code, response.message))
        return wx
    end
    wx.temp = lib.round(response.main.temp)
    wx.conditions = response.weather[1].main
    wx.icon = icons[response.weather[1].icon:sub(1, 2)]
    if config.units == METRIC then
        wx.units = 'C'
    elseif units == IMPERIAL then
        wx.units = 'F'
    else
        wx.units = 'K'
    end
    cache.write(response)
    return wx
end


-- Return a formatted version of the weather. For "full_text".
local getf = function(format)
    wx = get()
    str = string.gsub(format, '%%i', wx.icon)
    str = string.gsub(str, '%%t', wx.temp)
    str = string.gsub(str, '%%u', wx.units)
    str = string.gsub(str, '%%c', wx.conditions)
    return str
end


return {
  config = config,
  get = get,
  getf = getf,
  METRIC = METRIC,
  IMPERIAL = IMPERIAL
}
