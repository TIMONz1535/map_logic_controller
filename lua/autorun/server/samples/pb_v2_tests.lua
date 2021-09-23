--[[
	© 2021 PostBellum HL2 RP
	Author: TIMON_Z1535 - https://steamcommunity.com/profiles/76561198047725014
--]]
-- luacheck: globals hook ents

local function Init(controller, mapName)
	-- always check mapName to prevent script errors on other maps
	if mapName ~= "rp_pb_industrial17_v2" then
		return
	end

	local button1 = controller:GetMetaTarget("start_button_no")
	button1.OnPressed = function(ent, activator)
		print(activator, "just pressed", ent)
	end
	button1:Fire("Press") -- for test only

	local testActivator = button1[1] -- the first button activates the second button

	-- if entity has no name, we can pass it directly
	local button2 = controller:GetMetaTarget(ents.GetMapCreatedEntity(2591))
	button2.OnPressed = function(ent, activator)
		print(activator, "just pressed", ent)
	end
	button2:Fire("Press", nil, 1, testActivator, testActivator) -- delay 1 sec, activator is previous button
end

hook.Add("OnMapLogicInitialized", "pb_v2_tests", Init)
