-- © 2022 PostBellum HL2 RP. All rights reserved.

--[[
	Author: TIMON_Z1535 - https://steamcommunity.com/profiles/76561198047725014
	Repository: https://github.com/TIMONz1535/map_logic_controller
	Wiki: https://github.com/TIMONz1535/map_logic_controller/wiki
--]]
local META_TARGET = {
	nextOutputDelay = 0,
	nextOutputRepetitions = -1
}

-- Redirect the function call to internal entities.
META_TARGET.__index = function(self, key)
	if isnumber(key) then
		return
	end

	assert(#self > 0, ("no entities with name '%s', can't redirect method '%s'"):format(self.name, key))

	return function(_, ...)
		for _, v in ipairs(self) do
			if IsValid(v) then
				if not isfunction(v[key]) then
					local info = ("entity '%s' (%s)"):format(self.name, v:GetClass())
					error(("%s doesn't have a method '%s'"):format(info, key))
				end
				v[key](v, ...)
			end
		end
	end
end

-- Add output to internal entities that will be called on Lua-side by the controller.
META_TARGET.__newindex = function(self, output, callback)
	assert(#self > 0, ("no entities with name '%s', can't add output '%s'"):format(self.name, output))
	assert(IsValid(self.controller), ("invalid controller, can't add output '%s' for '%s'"):format(output, self.name))

	for _, v in ipairs(self) do
		if IsValid(v) then
			v.mapLogic = v.mapLogic or {}
			local prevFunc = v.mapLogic[output]
			v.mapLogic[output] = callback

			-- Don't call another AddOutput if we're just overriding a Lua function.
			if not prevFunc then
				if self.controller.statsOutputs then
					self.controller.statsOutputs = self.controller.statsOutputs + 1
				end

				-- To support the generated output values (like Position), leave the 'parameter' empty.
				v:Input(
					"AddOutput",
					self.controller,
					self.controller,
					("%s %s:__%s::%s:%s"):format(
						output,
						self.controller:GetName(),
						output,
						self.nextOutputDelay,
						self.nextOutputRepetitions
					)
				)
			end
		end
	end

	self.nextOutputDelay = 0
	self.nextOutputRepetitions = -1
end

META_TARGET.IsValid = function(self)
	local anyIsValid = false
	for _, v in ipairs(self) do
		anyIsValid = IsValid(v) or anyIsValid
	end
	return anyIsValid and IsValid(self.controller)
end

-- generates a unique id even if you call many times per second
local lastId = 0
local function GenerateSysId()
	lastId = math.max(lastId + 1, math.floor(SysTime()))
	return lastId
end

-- ====================================================================================================

local map_logic_override =
	CreateConVar("map_logic_override", "", FCVAR_NONE, "Overrides map name for which the controller will initialize the logic.")

ENT.Base = "base_point"
ENT.Type = "point"

function ENT:AcceptInput(input, activator, caller, value)
	if input:sub(1, 2) == "__" then
		local output = input:sub(3)

		-- currently there is no way to determine who is calling output
		assert(IsValid(caller), ("invalid caller for output '%s'"):format(output))
		assert(not caller:IsPlayer(), ("engine returns Player as caller for output '%s'"):format(output))

		if not istable(caller.mapLogic) then
			local info = ("entity '%s' (%s)"):format(caller:GetName(), caller:GetClass())
			error(("no mapLogic table in %s for calling the Lua-side output '%s'"):format(info, output))
		end

		local callback = caller.mapLogic[output]
		if not callback then
			local info = ("entity '%s' (%s)"):format(caller:GetName(), caller:GetClass())
			error(("no output function '%s' in mapLogic table of %s"):format(output, info))
		end

		callback(caller, activator, value)
		return true
	end
end

function ENT:GetMetaTarget(name)
	local entities
	if isstring(name) then
		assert(self.cache, ("no cache in controller, can't get MetaTarget for '%s'"):format(name))
		entities = self.cache[name] or {}
	elseif istable(name) then
		entities = name
		-- need to check all names, but it will be expensive
		name = name[1] and name[1]:GetName() or nil
	else
		entities = {name}
		name = name and name:GetName() or nil
	end

	if self.statsEntities then
		self.statsEntities = self.statsEntities + #entities
	end

	entities.name = name
	entities.controller = self
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
	self:SetName("map_logic_controller" .. GenerateSysId())

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

-- helper function to avoid copy-paste
function ENT:TimerSimple(delay, callback)
	timer.Simple(
		delay,
		function()
			if IsValid(self) then
				callback(self)
			end
		end
	)
end

function ENT:TimerCreate(identifier, delay, repetitions, callback)
	timer.Create(
		identifier,
		delay,
		repetitions,
		function()
			if IsValid(self) then
				callback(self)
			else
				timer.Remove(identifier)
			end
		end
	)
end

-- ====================================================================================================

local function Respawn()
	for _, v in ipairs(ents.FindByClass("map_logic_controller")) do
		v:Remove()
	end

	local ent = ents.Create("map_logic_controller")
	ent:Spawn()
end

hook.Add("InitPostEntity", "MapLogicSpawn", Respawn)
hook.Add("PostCleanupMap", "MapLogicSpawn", Respawn)

concommand.Add(
	"map_logic_reload",
	function(ply)
		if IsValid(ply) and not ply:IsSuperAdmin() then
			return
		end

		Respawn()
	end,
	nil,
	"Removes the old controller and creates a new one. Forces the entire map logic to be initialized again."
)
