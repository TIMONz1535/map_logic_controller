-- luacheck: globals ents ENT PB_GenerateTimeId Stack timer IsValid isnumber isfunction include MAP_CONTROLLER_FUNC

--[[
	Please don't create multiple map_logic_controllers.
	Unlock all doors for elevator.
	Disable all sounds for buttons on floor and in elevator.
	Repeat path tracks in the ring for hot reload.
--]]
include("cwhl2rp/gamemode/external/stack.lua")

local META_TARGET = {}

-- Симулирует вызов функции на энтити ent:SomeFunc()
META_TARGET.__index = function(self, key)
	if isnumber(key) then
		return self.entities[key]
	end
	return function(_, ...)
		for _, v in ipairs(self.entities) do
			if IsValid(v) then
				assert(isfunction(v[key]), "no valid method: " .. key)
				v[key](v, ...)
			end
		end
	end
end

-- Регистрирует OutputCallback для энтитей.
META_TARGET.__newindex = function(self, output, func)
	assert(#self.entities == 1, "attempt to register callback to multiple entities: " .. output)
	local ent = self.entities[1]
	assert(IsValid(ent), "no valid ent")

	ent["map_logic_" .. output] = func
	ent:Fire("AddOutput", ("%s %s:OutputCallback:%s:0:-1"):format(output, self.managerName, output))
end

-- ====================================================================================================

ENT.Base = "base_point"
ENT.Type = "point"

function ENT:AcceptInput(input, activator, ent, output)
	if input == "OutputCallback" then
		ent["map_logic_" .. output](ent, activator)
		return true
	end
end

function ENT:GetMetaTarget(name)
	assert(self.cache, "no cache in manager")
	local entities = self.cache[name]
	assert(entities, "no entities with name: " .. name)

	local metaTarget = {
		managerName = self:GetName(),
		entities = entities
	}
	return setmetatable(metaTarget, META_TARGET)
end

function ENT:CacheEntNames()
	local cache = {}
	for _, v in ipairs(ents.GetAll()) do
		if v:CreatedByMap() then
			local name = v:GetName()
			cache[name] = cache[name] or Stack()
			cache[name]:Push(v)
		end
	end
	self.cache = cache
end

function ENT:Initialize()
	-- no multiple controllers
	for _, v in ipairs(ents.FindByClass("map_logic_controller")) do
		if v ~= self then
			v:Remove()
		end
	end

	self:SetName("logic_manager_" .. PB_GenerateTimeId())
	self:CacheEntNames()
	MAP_CONTROLLER_FUNC = Stack()

	include("entities/map_logic_controller/office_elevator.lua")
	include("entities/map_logic_controller/med_elevator.lua")
	include("entities/map_logic_controller/city_elevator.lua")
	include("entities/map_logic_controller/metropol_elevator.lua")
	include("entities/map_logic_controller/beach_elevator.lua")
	include("entities/map_logic_controller/rebel_elevator.lua")
	include("entities/map_logic_controller/escape_door.lua")

	for _, func in ipairs(MAP_CONTROLLER_FUNC) do
		func(self)
	end
	MAP_CONTROLLER_FUNC = nil
	self.cache = nil
end
