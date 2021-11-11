--[[
	© 2021 PostBellum HL2 RP
	Author: TIMON_Z1535 - https://steamcommunity.com/profiles/76561198047725014
--]]
-- luacheck: globals hook timer util

local function Init(controller, mapName)
	if mapName ~= "rp_pb_industrial17_v2" then
		return
	end

	local elevator = controller:GetMetaTarget("med_elevator")
	local gate = controller:GetMetaTarget("med_elevator_gate")
	local button = controller:GetMetaTarget("med_elevator_button")
	local calls = {
		controller:GetMetaTarget("med_elevator_call1"),
		controller:GetMetaTarget("med_elevator_call2")
	}
	local doors = {
		controller:GetMetaTarget("med_elevator_door1"),
		controller:GetMetaTarget("med_elevator_door2")
	}

	local buttonDelay = 3
	elevator:SetKeyValue("speed", 50)
	elevator:DisableCombineUse()
	button:SetKeyValue("wait", buttonDelay)
	for _, v in ipairs(calls) do
		v:SetKeyValue("wait", buttonDelay)
	end
	for _, v in ipairs(doors) do
		v:DisableCombineUse()
	end

	gate:Fire("SetAnimation", "open")
	doors[1]:Fire("Open")

	local isMoving = false
	local targetFloor = 1

	local function MoveTo(floor)
		if isMoving or targetFloor == floor then
			return false
		end
		isMoving = true

		gate:Fire("SetAnimation", "close")
		doors[targetFloor]:Fire("Close")
		elevator:Fire("Toggle", nil, 1.5)

		targetFloor = floor
		return true
	end

	local function CheckFloor(floor)
		if targetFloor ~= floor then
			return false
		end

		doors[floor]:Fire("Open", nil, 1)
		gate:Fire("SetAnimation", "open", 1.5)
		util.ScreenShake(elevator[1]:GetPos(), 3, 1.5, 1, 80)

		timer.Simple(
			1.5 + buttonDelay,
			function()
				isMoving = false
			end
		)
		return true
	end

	button.OnPressed = function(ent, activator)
		local i = targetFloor == 1 and 2 or 1
		ent:EmitSound(MoveTo(i) and "buttons/button24.wav" or "buttons/button8.wav", 75)
	end
	for i, v in ipairs(calls) do
		v.OnPressed = function(ent, activator)
			ent:EmitSound(MoveTo(i) and "buttons/button24.wav" or "buttons/button8.wav", 75)
		end
	end
	elevator.OnFullyClosed = function(ent, activator)
		CheckFloor(1)
	end
	elevator.OnFullyOpen = function(ent, activator)
		CheckFloor(2)
	end
end

hook.Add("OnMapLogicInitialized", "pb_v2_med_elevator", Init)
