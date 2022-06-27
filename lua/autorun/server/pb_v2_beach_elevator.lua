--[[
	© 2021 PostBellum HL2 RP
	Author: TIMON_Z1535 - https://steamcommunity.com/profiles/76561198047725014
--]]
-- luacheck: globals hook timer util

local function Init(controller, mapName)
	if mapName ~= "rp_pb_industrial17_v2" then
		return
	end

	local elevator = controller:GetMetaTarget("beach_elevator")
	local paths = {
		controller:GetMetaTarget("beach_elevator_path1"),
		controller:GetMetaTarget("beach_elevator_path2"),
		controller:GetMetaTarget("beach_elevator_path3"),
		controller:GetMetaTarget("beach_elevator_path4")
	}
	local buttons = {
		controller:GetMetaTarget("beach_elevator_button1"),
		controller:GetMetaTarget("beach_elevator_button2"),
		controller:GetMetaTarget("beach_elevator_button3"),
		controller:GetMetaTarget("beach_elevator_button4")
	}
	local calls = {
		controller:GetMetaTarget("beach_elevator_call1"),
		controller:GetMetaTarget("beach_elevator_call2"),
		controller:GetMetaTarget("beach_elevator_call3"),
		controller:GetMetaTarget("beach_elevator_call4")
	}

	local buttonDelay = 3
	elevator:SetKeyValue("startspeed", 40)
	for _, v in ipairs(buttons) do
		v:SetKeyValue("wait", buttonDelay)
	end
	for _, v in ipairs(calls) do
		v:SetKeyValue("wait", buttonDelay)
	end

	local isMoving = false
	local targetFloor = 1

	local function MoveTo(floor)
		if isMoving or targetFloor == floor then
			return false
		end
		isMoving = true

		elevator:Fire(targetFloor < floor and "StartForward" or "StartBackward", nil, 1.5)

		targetFloor = floor
		return true
	end

	local function CheckFloor(floor)
		if targetFloor ~= floor then
			return false
		end

		elevator:Fire("Stop")
		util.ScreenShake(elevator[1]:GetPos(), 2, 1.5, 1, 180)

		controller:TimerSimple(
			1.5 + buttonDelay,
			function()
				isMoving = false
			end
		)
		return true
	end

	for i, v in ipairs(buttons) do
		v.OnPressed = function(ent, activator)
			ent:EmitSound(MoveTo(i) and "buttons/button24.wav" or "buttons/button8.wav", 75)
		end
	end
	for i, v in ipairs(calls) do
		v.OnPressed = function(ent, activator)
			ent:EmitSound(MoveTo(i) and "buttons/button24.wav" or "buttons/button8.wav", 75)
		end
	end
	for i, v in ipairs(paths) do
		v.OnPass = function(ent, activator)
			CheckFloor(i)
		end
	end
end

hook.Add("OnMapLogicInitialized", "pb_v2_beach_elevator", Init)
