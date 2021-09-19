--[[
	© 2021 PostBellum HL2 RP
	Author: TIMON_Z1535 - http://steamcommunity.com/profiles/76561198047725014
--]]
-- luacheck: globals ENT IsValid isnumber isfunction isstring istable ents timer game engine hook
-- luacheck: globals MsgN CreateConVar concommand FCVAR_NONE

--[[
	Please don't create multiple map_logic_controllers.
	Unlock all doors for elevator.
	Disable all sounds for buttons on floor and in elevator.
	Repeat path tracks in the ring for hot reload.
--]]
local META_TARGET = {}

-- Redirect the function call to the internal entities
META_TARGET.__index = function(self, key)
	if isnumber(key) then
		return
	end
	return function(_, ...)
		for _, v in ipairs(self) do
			if IsValid(v) then
				assert(isfunction(v[key]), "no valid method: " .. key)
				v[key](v, ...)
			end
		end
	end
end

-- Регистрирует обратный вызов на нужный оутпут, который отсылается в контроллер.
META_TARGET.__newindex = function(self, output, func)
	assert(#self ~= 0, "attempt to register callback to empty entities: " .. output)
	for _, v in ipairs(self) do
		assert(IsValid(v), "no valid ent")

		v.mapLogic = v.mapLogic or {}
		local prevFunc = v.mapLogic[output]
		v.mapLogic[output] = func

		-- Don't call another AddOutput if we're just overriding a Lua function.
		if not prevFunc then
			self.controller.statsOutputs = self.controller.statsOutputs + 1

			-- To support the generated output values (like Position), leave the 'parameter' empty.
			v:Input(
				"AddOutput",
				self.controller,
				self.controller,
				("%s %s:__%s::0:-1"):format(output, self.controllerName, output)
			)
		end
	end
end

-- ====================================================================================================

local map_logic_override =
	CreateConVar(
	"map_logic_override",
	"",
	FCVAR_NONE,
	"Overrides map name for which the controller will initialize the logic."
)

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
	local entities
	if isstring(name) then
		assert(self.cache, "no cache in controller")
		entities = self.cache[name] or {}
	else
		entities = {name}
	end

	self.statsEntities = self.statsEntities + #entities

	entities.controller = self
	entities.controllerName = self:GetName()
	return setmetatable(entities, META_TARGET)
end

function ENT:CacheEntNames()
	local cache = {}
	for _, v in ipairs(ents.GetAll()) do
		local name = v:GetName()
		if name ~= "" then
			cache[name] = cache[name] or {}
			table.insert(cache[name], v)
		end
	end
	self.cache = cache
end

function ENT:InitializeLogic()
	self:CacheEntNames()
	self:SetName("map_logic_controller" .. PB_GenerateTimeId())

	local mapName = map_logic_override:GetString()
	if mapName == "" then
		mapName = game.GetMap()
	end

	self.statsEntities = 0
	self.statsOutputs = 0
	hook.Run("OnMapLogicInitialized", self, mapName)
	self.cache = nil

	-- Map is not configured, the controller is useless.
	if self.statsEntities == 0 and self.statsOutputs == 0 then
		MsgN("[MapLogic] No logic for '", mapName, "', controller will be removed...")
		self:Remove()
		return
	end

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

function ENT:Initialize()
	-- Wait for second frame because OnRemove is executed in next frame.
	-- Also it allows you rename map entities in InitPostEntity.
	local delay = engine.TickInterval() * 2
	self:TimerSimple(delay, self.InitializeLogic)
end

function ENT:OnRemove()
	for _, v in ipairs(ents.GetAll()) do
		if v.mapLogic then
			v.mapLogic = nil
		end
	end
end

-- helper function
function ENT:TimerSimple(time, func)
	timer.Simple(
		time,
		function()
			if IsValid(self) then
				func(self)
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

		for _, v in ipairs(ents.FindByClass("map_logic_controller")) do
			v:Remove()
		end

		local ent = ents.Create("map_logic_controller")
		ent:Spawn()
	end
)
