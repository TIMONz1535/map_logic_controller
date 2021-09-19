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

-- Регистрирует обратный вызов на нужный оутпут, который отсылается в контроллер.
META_TARGET.__newindex = function(self, output, func)
	assert(#self.entities == 1, "attempt to register callback to multiple entities: " .. output)
	local ent = self.entities[1]
	assert(IsValid(ent), "no valid ent")

	self.controller.statsOutputs = self.controller.statsOutputs + 1

	ent.mapLogic = ent.mapLogic or {}
	ent.mapLogic[output] = func

	-- Don't write any to parameter for support outputs with changeable values, like Position
	ent:Fire("AddOutput", ("%s %s:__%s::0:-1"):format(output, self.controllerName, output))
end

-- ====================================================================================================

ENT.Base = "base_point"
ENT.Type = "point"

function ENT:AcceptInput(input, activator, ent, value)
	if input:sub(1, 2) == "__" then
		local output = input:sub(3)
		local info = ("%s %s:%s (%s) - "):format(tostring(ent), output, tostring(activator), value)
		assert(not ent:IsPlayer(), info .. "engine logic returns Player as caller entity, sorry you are out of luck")
		assert(istable(ent.mapLogic), info .. "entity doesn't have mapLogic table")

		local func = ent.mapLogic[output]
		assert(func, info .. "entity's mapLogic table doesn't have output func")

		func(ent, activator, value)
		return true
	end
end

function ENT:GetMetaTarget(name)
	assert(self.cache, "no cache in controller")
	local entities = self.cache[name]
	assert(entities, "no entities with name: " .. name)

	self.statsEntities = self.statsEntities + #entities

	local metaTarget = {
		controller = self,
		controllerName = self:GetName(),
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

	self:SetName("map_logic_controller" .. PB_GenerateTimeId())
	self:CacheEntNames()

	local mapName = game.GetMap()

	self.statsEntities = 0
	self.statsOutputs = 0
	hook.Run("OnMapLogicInitialized", self, mapName)
	self.cache = nil

	MsgN(
		"[MapLogic] Initialized successfully for '",
		mapName,
		"' (affected entities: ",
		self.statsEntities,
		", added outputs: ",
		self.statsOutputs,
		")"
	)
	self.statsEntities = nil
	self.statsOutputs = nil
end

-- helper function
function ENT:TimerSimple(time, func)
	timer.Simple(
		time,
		function()
			if IsValid(self) then
				func()
			end
		end
	)
end

-- ====================================================================================================

hook.Add(
	"InitPostEntity",
	"MapLogicSpawn",
	function()
		local ent = ents.Create("map_logic_controller")
		ent:Spawn()
	end
)

concommand.Add(
	"map_logic_reset",
	function(ply)
		if IsValid(ply) and not ply:IsSuperAdmin() then
			return
		end

		-- TODO
		for _, v in ipairs(ents.FindByClass("map_logic_controller")) do
			v:Remove()
		end

		local ent = ents.Create("map_logic_controller")
		ent:Spawn()
	end
)
