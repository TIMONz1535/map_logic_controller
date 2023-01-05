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
	Vector(-1940, 7120 + 16, -136),
	Vector(-1940 - 8, 7120, -136),
	Vector(-1940, 7120 - 16, -136),
	Vector(-1884, 7120, 168)
}

local function Init(controller, mapName)
	if mapName ~= "rp_pb_industrial17_v2" then
		return
	end

	-- remove touch flag on main dungeon door
	local dungeon_door = controller:GetMetaTarget("danger_door")
	dungeon_door:SetKeyValue("spawnflags", 0)
	dungeon_door:DisableCombineUse()

	-- make block_d fridge door usable
	local fridge_door = controller:GetMetaTarget("fridgedoor_00_1")
	fridge_door:SetKeyValue("spawnflags", 274)
	-- manually apply reverse dir flag
	local ang1 = fridge_door[1]:GetInternalVariable("m_vecAngle1")
	local moveAng = -fridge_door[1]:GetInternalVariable("m_vecMoveAng")
	local moveDist = fridge_door[1]:GetInternalVariable("m_flMoveDistance")
	fridge_door[1]:SetSaveValue("m_vecMoveAng", moveAng)
	fridge_door[1]:SetSaveValue("m_vecAngle2", ang1 + moveAng * moveDist)

	-- make warehouse6 door toggleable
	local warehouse6_door = controller:GetMetaTarget("warehouse_door6")
	warehouse6_door:SetKeyValue("spawnflags", 32)
	local warehouse6_button = controller:GetMetaTarget(ents.GetMapCreatedEntity(2003))
	warehouse6_button:ClearAllOutputs()
	warehouse6_button.OnPressed = function(ent, activator)
		warehouse6_door:Fire("Toggle")
	end

	-- remove useless blocklight door
	SafeRemoveEntity(ents.GetMapCreatedEntity(5041))

	-- make fence doors toggleable and usable to everyone, because they controlled by Combine locks
	local fence_doors = {
		controller:GetMetaTarget("ration_northfence_door"),
		controller:GetMetaTarget("ration_southfence_door"),
		controller:GetMetaTarget("fencedoor1"),
		controller:GetMetaTarget("fencedoor2"),
		controller:GetMetaTarget("fencedoor3"),
		controller:GetMetaTarget("fencedoor5"),
		controller:GetMetaTarget("fencedoor6"),
		controller:GetMetaTarget("fencedoor7"),
		controller:GetMetaTarget("fencedoor8"),
		controller:GetMetaTarget("fencedoor9"),
		controller:GetMetaTarget("fencedoor10"),
		controller:GetMetaTarget("fencedoor11"),
		controller:GetMetaTarget("fencedoor12")
	}
	for _, v in ipairs(fence_doors) do
		v:SetKeyValue("spawnflags", 288)
		v:SetKeyValue("forceclosed", 0)
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
	if ration_button[1]:GetSpawnFlags() == 292 then
		return
	end
	-- make the func_door usable, otherwise it will be permanently opened by Combines
	ration_button:SetKeyValue("spawnflags", 292)
	-- fix wait delay of the toggleable func_door
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
