-- © 2022 PostBellum HL2 RP. All rights reserved.

local function Init(controller, mapName)
	if mapName ~= "rp_pb_industrial17_v2" then
		return
	end

	local unusable_doors = {
		-- secret doors
		-- rebels
		controller:GetMetaTarget("secret_box1"),
		controller:GetMetaTarget("sewer_secretdoor"),
		-- metropol
		controller:GetMetaTarget("secret_box2"),
		controller:GetMetaTarget("slums_secretdoor2"),
		controller:GetMetaTarget("slums_secretdoor3"),
		-- cinema
		controller:GetMetaTarget("sewer_secretdoor2"),
		controller:GetMetaTarget("sewer_secretdoor3"),
		-- grizzly
		controller:GetMetaTarget("secret_box3"),
		controller:GetMetaTarget("grizzly_secretdoor"),
		controller:GetMetaTarget("grizzly_sewerdoor"),
		-- d5
		controller:GetMetaTarget("westside_door"),
		controller:GetMetaTarget("westside_backdoor"),
		-- quarantine
		controller:GetMetaTarget("door_metalplate"),
		--
		-- city train
		controller:GetMetaTarget("train_door_2"),
		controller:GetMetaTarget("station_gate_01"),
		controller:GetMetaTarget("station_gate_02"),
		-- nexus train
		controller:GetMetaTarget("nn_train_door_cp"),
		controller:GetMetaTarget("nn_train_door_cit"),
		-- square tv
		controller:GetMetaTarget("screen_arm_tube1"),
		controller:GetMetaTarget("screen_arm_tube2"),
		controller:GetMetaTarget("screen_arm_rotate"),
		-- rebels canal doors
		controller:GetMetaTarget("sewer_gendoor"),
		-- d5/d7 door
		controller:GetMetaTarget("d5_new_door"),
		-- rebels jail
		controller:GetMetaTarget("rebel_cell_door"),
		-- combine beach doors
		controller:GetMetaTarget("outerbulkhead"),
		-- combine lockdown doors
		controller:GetMetaTarget("lockdowndoors"),
		controller:GetMetaTarget("lockdowndoor2"),
		-- nexus bridge
		controller:GetMetaTarget("consul_bridge"),
		-- elevators
		controller:GetMetaTarget("tunnel_elevator1_gratedoor"),
		controller:GetMetaTarget("elevator1_door"),
		controller:GetMetaTarget("nexus_elevator1"),
		controller:GetMetaTarget("nexus_elevator2"),
		controller:GetMetaTarget("nexus_elevator3"),
		controller:GetMetaTarget("nexus_elevator4"),
		controller:GetMetaTarget("nexus_lowerelevator"),
		controller:GetMetaTarget("nexus_upperelevator")
	}

	for _, v in ipairs(unusable_doors) do
		v:DisableCombineUse()
	end

	-- remove d5 secret buttons, because replaced with keypad
	SafeRemoveEntity(ents.GetMapCreatedEntity(2339))
	SafeRemoveEntity(ents.GetMapCreatedEntity(2396))
end

hook.Add("OnMapLogicInitialized", "pb_v2_unusable_doors", Init)
