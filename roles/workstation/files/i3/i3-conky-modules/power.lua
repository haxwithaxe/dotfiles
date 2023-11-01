json = require('json')

local lib = require('lib')
log = lib.log:new({level=lib.log.ERROR})


local config = {
	good_color = '00ff00',
	warn_color = 'ffff00',
	danger_color = 'ff0000',
	charge_color = '9090ff',
	critical_battery_percent = 10,
	sys = {
		power_supply_path = '/sys/class/power_supply/',
		battery_name = 'BAT0',
		battery_full = 'charge_full',
		battery_now = 'charge_now',
		battery_status = 'status'
	}
}


local icons = {
	battery = '⚡',
	ac = '⏚',
	unknown = '∅'
}


local SysInfo = function(path, cast)
	cast = cast or tostring
	get = function(self)
		local fh = assert(io.open(path, "rb"))
		if not fh then
			log:err("Can't find '%s'", path)
			return cast('-1')
		end
		local contents = assert(fh:read("*a"))
		fh:close()
		r = cast(contents)
		return r
	end
	return get
end


local Battery = {

	new = function(self, path)
		setmetatable({}, self)
		self.__index = self
		self.path = path
		self.full = SysInfo(path .. '/' .. config.sys.battery_full, tonumber)
		self.now = SysInfo(path .. '/' .. config.sys.battery_now, tonumber)
		self.status = SysInfo(path .. '/' .. config.sys.battery_status)
		return self
	end,

	perc = function(self)
		return lib.round((self:now()/self:full())*100)
	end,

	is_discharging = function(self)
		status = self:status()
		log:debug('is_discharging{status} = %s', status)
		return status == 'Discharging'
	end,

	tostring = function(self)
		return 'Battery: filename = ' .. self.filename .. ', full = ' .. self:full() .. ', now = ' .. self:now() .. ', status = ' .. self:is_discharging()
	end
}


function format_type(obj)
	if type(obj) == 'number' then
		return ('[num:%s]'):format(tostring(obj))
	end
	if type(obj) == 'string' then
		return ('"%s"'):format(obj)
	end
	return tostring(obj)
end


function dump(obj)
	if type(obj) == 'table' then
		local s = '{'
		for k, v in pairs(obj) do
			k = format_type(k)
			s = s .. k .. ' = ' .. dump(v) .. ', '
		end
		return s
	else
		return format_type(o)
	end
end


local all_now = function(batteries)
	value = 0
	for _, b in pairs(batteries) do
		got = b:now()
		value = value + tonumber(got or -1)
	end
	return value
end


local all_full = function(batteries)
	value = 0
	for _, b in pairs(batteries) do
		value = value + b:full()
	end
	return value
end


local all_perc = function(batteries)
	return lib.round((all_now(batteries)/all_full(batteries))*100)
end


local PowerSupply = {

	new = function(self, batt, path, ...)
		setmetatable({}, self)
		self.__index = self
		if arg == nil then
			self.format = "%s:%3d"
		else
			self.format = arg.format
		end
		path = path or config.sys.power_supply_path
		self.batteries = {}
		table.insert(self.batteries, Battery:new(path .. '/' .. batt))
		return self
	end,

	is_on_ac = function(self)
		for _, battery in pairs(self.batteries) do
			log:debug('Battery{path = %s, is_discharging = %s', battery.path, tostring(battery:is_discharging()))
			if battery:is_discharging() then
				return false
			end
		end
	end,

	is_charged = function(self)
		return self:is_on_ac() and all_perc(self.batteries) >= 100
	end,

	is_critical = function(self)
		return all_perc(self.batteries) <= config.critical_battery_percent
	end,

	get_state = function(self)
		-- initial state indicators
		battery_perc = all_perc(self.batteries)
		symbol = icons.battery
		color = config.danger_color
		-- real state
		plugged_in = self:is_on_ac()
		fully_charged = self:is_charged()
		critically_low = self:is_critical()

		if plugged_in then
			log:debug('Plugged in.')
			symbol = icons.ac
			if fully_charged then
				log:debug('Fully charged.')
				color = config.good_color
			else
				log:debug('Charging')
				color = config.charge_color
			end
		elseif not critically_low then
			-- Discharging and not critical
			log:debug('Discharging and not critical')
			color = config.warn_color
		end

		log:debug(
			'is_on_ac = %s, is_charged = %s, is_critical = %s, ', 
			tostring(plugged_in), 
			tostring(fully_charged), 
			tostring(critically_low)
			)
		return { perc = battery_perc, icon = symbol, color = color }
	end,

	full_text = function(self)
		state = self:get_state()
		return self.format:format(state.icon, state.perc)
	end,

	color = function(self)
		state = self:get_state()
		return state.color
	end,

	conky_spec = function(self)
		state = self:get_state()
		return { full_text = self.format:format(state.icon, state.perc), color = state.color }
	end
}

return {
	power_supply = PowerSupply,
	config = config,
	icons = icons
}
