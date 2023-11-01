
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

	_format = function(level_name, fmt, values)
		local message = '%s: %s\n'
		if values ~= nil then
			if type(values) == type({}) then
				fmt = string.format(fmt, unpack(values))
			else
				fmt = string.format(fmt, values)
			end
		end
		return string.format(message, level_name, fmt)
	end,

	log = function(self, level, fmt, values)
		if self.level.index >= level.index then
			self:write(self._format(level.name, fmt, values))
		end
	end,

	debug = function(self, format, ...)
		self:log(self.DEBUG, format, arg)
	end,

	err = function(self, format, ...)
		self:log(self.ERROR, format, arg)
	end,

	info = function(self, format, ...)
		self:log(self.INFO, format, arg)
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
	sum = sum
}
