-- © 2022 PostBellum HL2 RP. All rights reserved.

local buttonDelay = 3
local buttonSound = "buttons/button24.wav"
local buttonSoundFail = "buttons/button8.wav"
local moveDelay = 1.5
local stopDelay = 1

local function Init(controller, mapName)
	if mapName ~= "rp_pb_industrial17_v2" then
		return
	end

	local elevator = controller:GetMetaTarget("nn_down_elevator")
	local elevator_button = controller:GetMetaTarget("nn_elevator_buttons")
	local elevator_shield = controller:GetMetaTarget("nn_elevator_clip")

	local floor_calls = {
		controller:GetMetaTarget(ents.GetMapCreatedEntity(4368)),
		controller:GetMetaTarget(ents.GetMapCreatedEntity(4987))
	}
	local floor1_shield = controller:GetMetaTarget("nn_elevator_down_clip")
	local floor1_model = controller:GetMetaTarget("nn_elevator_combineshield")
	local floor2_door = controller:GetMetaTarget("nn_elevator_door")

	local paths = {
		controller:GetMetaTarget("nn_elevator_path1"),
		controller:GetMetaTarget("nn_elevator_path2")
	}

	-- ====================================================================================================
	-- setup

	elevator:SetKeyValue("startspeed", 50)
	elevator:ClearAllOutputs()
	elevator_button:SetKeyValue("wait", buttonDelay)
	elevator_button:ClearAllOutputs()

	for _, v in ipairs(floor_calls) do
		v:SetKeyValue("wait", buttonDelay)
		v:ClearAllOutputs()
	end
	floor2_door:DisableCombineUse()
	floor2_door:ClearAllOutputs()

	for _, v in ipairs(paths) do
		v:ClearAllOutputs()
	end

	-- disable toggle flag
	elevator_button:SetKeyValue("spawnflags", 1025)
	elevator_shield:Fire("Disable")
	-- elevator is on second floor on spawn
	floor2_door:Fire("Unlock")
	floor2_door:Fire("Open")
	-- fix floor2 stop point position
	local pos = paths[2][1]:GetPos()
	pos.z = 114
	paths[2]:SetPos(pos)

	-- ====================================================================================================
	-- movement

	local isMoving = false
	local targetFloor = 2

	local function MoveTo(floor)
		if isMoving or targetFloor == floor then
			return false
		end
		isMoving = true

		elevator_shield:Fire("Enable")
		if targetFloor == 1 then
			floor1_shield:Fire("Enable")
			floor1_model:Fire("Skin", 0)
		else
			floor2_door:Fire("Close")
		end
		elevator:Fire(targetFloor < floor and "StartForward" or "StartBackward", nil, moveDelay)

		targetFloor = floor
		return true
	end

	local function CheckFloor(floor)
		if targetFloor ~= floor then
			return false
		end

		elevator:Fire("Stop")
		elevator_shield:Fire("Disable", nil, stopDelay)
		if targetFloor == 1 then
			floor1_shield:Fire("Disable", nil, stopDelay)
			floor1_model:Fire("Skin", 1, stopDelay)
		else
			floor2_door:Fire("Open", nil, stopDelay)
		end
		util.ScreenShake(elevator[1]:GetPos(), 1, 1.5, stopDelay, 80)

		controller:TimerSimple(
			buttonDelay + moveDelay,
			function()
				isMoving = false
			end
		)
		return true
	end

	elevator_button.OnPressed = function(ent, activator, caller, value)
		local i = targetFloor == 1 and 2 or 1
		ent:EmitSound(MoveTo(i) and buttonSound or buttonSoundFail)
	end

	for i, v in ipairs(floor_calls) do
		v.OnPressed = function(ent, activator, caller, value)
			ent:EmitSound(MoveTo(i) and buttonSound or buttonSoundFail)
		end
	end

	for i, v in ipairs(paths) do
		v.OnPass = function(ent, activator, caller, value)
			CheckFloor(i)
		end
	end
end

hook.Add("OnMapLogicInitialized", "pb_v2_nn_elevator", Init)
