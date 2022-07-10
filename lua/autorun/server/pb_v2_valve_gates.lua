-- © 2022 PostBellum HL2 RP. All rights reserved.

local function Init(controller, mapName)
	if mapName ~= "rp_pb_industrial17_v2" then
		return
	end

	do
		local valve1 = controller:GetMetaTarget("gate1_wheel")
		local valve2 = controller:GetMetaTarget("gate1_wheel2")
		local gate = controller:GetMetaTarget("door_lock1")

		local position1 = 0
		local position2 = 0

		valve1.Position = function(ent, activator, caller, value)
			position1 = value
			gate:Fire("SetPosition", math.max(position1, position2))
		end
		valve2.Position = function(ent, activator, caller, value)
			position2 = value
			gate:Fire("SetPosition", math.max(position1, position2))
		end
	end

	do
		local valve1 = controller:GetMetaTarget("gate3_wheel")
		local valve2 = controller:GetMetaTarget("gate3_wheel2")
		local gate = controller:GetMetaTarget("door_lock2_2")

		local position1 = 0
		local position2 = 0

		valve1.Position = function(ent, activator, caller, value)
			position1 = value
			gate:Fire("SetPosition", math.max(position1, position2))
		end
		valve2.Position = function(ent, activator, caller, value)
			position2 = value
			gate:Fire("SetPosition", math.max(position1, position2))
		end
	end
end

hook.Add("OnMapLogicInitialized", "pb_v2_valve_gates", Init)
