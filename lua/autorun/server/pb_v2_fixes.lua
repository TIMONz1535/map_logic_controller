-- © 2022 PostBellum HL2 RP. All rights reserved.

-- fix of sound flooding, due to network lags
hook.Add(
	"AcceptInput",
	"TrainSoundFix",
	function(ent, input, activator, caller, value)
		if input == "Stop" and ent:GetClass() == "func_tracktrain" then
			ent:StopSound(ent:GetInternalVariable("m_iszSoundMove"))
		end
	end
)

-- You can debug ladders with `developer 1; sv_showladders 1`.
local dismounts = {
	-- canals
	Vector(-1940, 7120 + 16, -136),
	Vector(-1940 - 8, 7120, -136),
	Vector(-1940, 7120 - 16, -136),
	Vector(-1884, 7120, 168)
}

local function Init(controller, mapName)
	if mapName ~= "rp_pb_industrial17_v2" then
		return
	end

	local ladder = ents.Create("func_useableladder")
	ladder:SetPos(Vector(-1940, 7120, -120))
	ladder:SetKeyValue("point0", "-1940 7120 -120")
	ladder:SetKeyValue("point1", "-1940 7120 144")
	ladder:Spawn()
	controller:DeleteOnRemove(ladder)

	-- Нет необходимости привязывать по имени, лестница при активации ищет их вокруг себя.
	for _, v in ipairs(dismounts) do
		local dismount = ents.Create("info_ladder_dismount")
		dismount:SetPos(v)
		dismount:Spawn()
		controller:DeleteOnRemove(dismount)
	end

	ladder:Activate()

	local ladderProp = ents.Create("prop_dynamic")
	ladderProp:SetPos(Vector(-1920, 7120, -72))
	ladderProp:SetAngles(Angle())
	ladderProp:SetModel("models/props_c17/metalladder004.mdl")
	ladderProp:SetSkin(1)
	ladderProp:SetKeyValue("DisableBoneFollowers", 1)
	ladderProp:SetKeyValue("solid", 6)
	ladderProp:DrawShadow(false)
	ladderProp:Spawn()
	controller:DeleteOnRemove(ladderProp)
	ladderProp.PhysgunDisabled = true
	ladderProp.CanTool = function()
		return false
	end

	-- prevents players ragdolls teleportation
	local filter = ents.Create("filter_activator_class")
	filter:SetKeyValue("filterclass", "prop_ragdoll")
	filter:SetKeyValue("negated", "1")
	filter:Spawn()
	controller:DeleteOnRemove(filter)
	local nexus_ga_teleport = controller:GetMetaTarget("letters_teleport")
	nexus_ga_teleport:SetSaveValue("m_hFilter", filter)

	local ration_button = controller:GetMetaTarget(ents.GetMapCreatedEntity(4546))
	if ration_button[1]._usableFixed then
		return
	end
	-- make the func_door usable, otherwise it will be permanently opened by Combines
	ration_button:SetKeyValue("spawnflags", 292)
	-- fix wait delay of the toggled func_door
	ration_button.OnClose = function(ent, activator)
		ent:Fire("Lock")
		controller:TimerSimple(
			60,
			function()
				ent:Fire("Unlock")
			end
		)
	end
	ration_button.OnOpen = function(ent, activator)
		ent:Fire("Lock")
		controller:TimerSimple(
			60,
			function()
				ent:Fire("Unlock")
			end
		)
	end
end

hook.Add("OnMapLogicInitialized", "pb_v2_fixes", Init)
