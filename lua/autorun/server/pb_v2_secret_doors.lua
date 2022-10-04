-- © 2022 PostBellum HL2 RP. All rights reserved.

local function Init(controller, mapName)
	if mapName ~= "rp_pb_industrial17_v2" then
		return
	end

	local box1 = controller:GetMetaTarget("secret_box1")
	local box2 = controller:GetMetaTarget("secret_box2")
	local box3 = controller:GetMetaTarget("secret_box3")
	local rebel_door = controller:GetMetaTarget("sewer_secretdoor")
	local cinema1 = controller:GetMetaTarget("sewer_secretdoor2")
	local cinema2 = controller:GetMetaTarget("sewer_secretdoor3")
	local toiler_door = controller:GetMetaTarget("grizzly_secretdoor")
	local metropol_door = controller:GetMetaTarget("slums_secretdoor2")
	local metropol_window = controller:GetMetaTarget("slums_secretdoor3")
	local puzzle_door = controller:GetMetaTarget("grizzly_sewerdoor")

	box1:DisableCombineUse()
	box2:DisableCombineUse()
	box3:DisableCombineUse()
	rebel_door:DisableCombineUse()
	cinema1:DisableCombineUse()
	cinema2:DisableCombineUse()
	toiler_door:DisableCombineUse()
	metropol_door:DisableCombineUse()
	metropol_window:DisableCombineUse()
	puzzle_door:DisableCombineUse()

	-- remove secret buttons, because replaced with keypad
	SafeRemoveEntity(ents.GetMapCreatedEntity(2339))
	SafeRemoveEntity(ents.GetMapCreatedEntity(2396))
end

hook.Add("OnMapLogicInitialized", "pb_v2_secret_doors", Init)
