
local math = require('math')

local sum = function(tbl, func)
	total = 0
	for _, v in tbl do
		if type(v) ~= 'number' then
			error('value"'..tostring(v)..'" is type '..type(v)..' not a number.')
		end
		total = total + v
	end
	return total
end


local log = {

	ERROR = {index = 1, name = 'ERROR'},
	INFO = {index = 2, name = 'INFO'},
	DEBUG = {index = 3, name = 'DEBUG'},
	level = nil,

	write = function(self, message)
		io.stderr:write(message)
	end,

	_format = function(level_name, fmt, ...)
		local message = '%s: %s\n'
        args = {...}
		if #args > 0 then
            for k, v in pairs(args) do
                args[k] = tostring(v)
            end
			fmt = string.format(fmt, ...)
		end
		return string.format(message, level_name, fmt)
	end,

	log = function(self, level, fmt, ...)
		if self.level.index >= level.index then
			self:write(self._format(level.name, fmt, ...))
		end
	end,

	debug = function(self, format, ...)
		self:log(self.DEBUG, format, ...)
	end,

	err = function(self, format, ...)
		self:log(self.ERROR, format, ...)
	end,

	info = function(self, format, ...)
		self:log(self.INFO, format, ...)
	end

}

log.__index = log

function log:new(conf)
	conf = conf or {}
	if conf.level == nil then
		conf.level = log.ERROR
	end
	setmetatable(conf, log)
	return conf
end

return {
	log = log,
	round = function(num) return math.floor(num + 0.5) end,
	sum = sum,
    trim = trim
}
