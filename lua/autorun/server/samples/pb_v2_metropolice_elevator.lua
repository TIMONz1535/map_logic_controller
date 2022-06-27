-- © 2022 PostBellum HL2 RP. All rights reserved.

hook.Add(
	"PlayerSay",
	"ElevatorWaitForApply",
	function(ply, text)
		if ply.waitForApply then
			if text:sub(1, 4) == "id: " then
				ply.waitForApply()
				ply.waitForApply = nil
				ply.waitEnt = nil
			elseif IsValid(ply.waitEnt) then
				ply.waitEnt:EmitSound("npc/metropolice/vo/getoutofhere.wav")
				ply.waitForApply = nil
				ply.waitEnt = nil
			end
		end
	end
)

local function Init(controller, mapName)
	if mapName ~= "rp_pb_industrial17_v2" then
		return
	end

	local elevator = controller:GetMetaTarget("metropol_elevator")
	local gate = controller:GetMetaTarget("metropol_elevator_gate")
	local paths = {
		controller:GetMetaTarget("metropol_elevator_path1"),
		controller:GetMetaTarget("metropol_elevator_path2"),
		controller:GetMetaTarget("metropol_elevator_path3"),
		controller:GetMetaTarget("metropol_elevator_path4"),
		controller:GetMetaTarget("metropol_elevator_path5")
	}
	local buttons = {
		controller:GetMetaTarget("metropol_elevator_button1"),
		controller:GetMetaTarget("metropol_elevator_button2"),
		controller:GetMetaTarget("metropol_elevator_button3"),
		controller:GetMetaTarget("metropol_elevator_button4"),
		controller:GetMetaTarget("metropol_elevator_button5")
	}
	local calls = {
		controller:GetMetaTarget("metropol_elevator_call1"),
		controller:GetMetaTarget("metropol_elevator_call2"),
		controller:GetMetaTarget("metropol_elevator_call3"),
		controller:GetMetaTarget("metropol_elevator_call4"),
		controller:GetMetaTarget("metropol_elevator_call5")
	}
	local doors = {
		controller:GetMetaTarget("metropol_elevator_door1"),
		controller:GetMetaTarget("metropol_elevator_door2"),
		controller:GetMetaTarget("metropol_elevator_door3"),
		controller:GetMetaTarget("metropol_elevator_door4"),
		controller:GetMetaTarget("metropol_elevator_door5")
	}

	local buttonDelay = 1
	elevator:SetKeyValue("startspeed", 50)
	for _, v in ipairs(buttons) do
		v:SetKeyValue("wait", buttonDelay)
	end
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

	local music
	controller:CallOnRemove(
		"StopElevatorMusic",
		function()
			if music then
				music:Stop()
			end
		end
	)

	local function MoveTo(floor)
		if isMoving or targetFloor == floor then
			return false
		end
		isMoving = true

		gate:Fire("SetAnimation", "close")
		doors[targetFloor]:Fire("Close")
		elevator:Fire(targetFloor < floor and "StartForward" or "StartBackward", nil, 1.5)

		controller:TimerSimple(
			2,
			function()
				music = CreateSound(elevator[1], "music/hl2_song31.mp3")
				music:Play()
			end
		)

		targetFloor = floor
		return true
	end

	local function CheckFloor(floor)
		if targetFloor ~= floor then
			return false
		end

		controller:TimerSimple(
			0.5,
			function()
				elevator:EmitSound("plats/elevbell1.wav")
			end
		)
		if music then
			music:Stop()
			music = nil
		end
		elevator:Fire("Stop")
		doors[floor]:Fire("Open", nil, 1)
		gate:Fire("SetAnimation", "open", 1.5)
		util.ScreenShake(elevator[1]:GetPos(), 3, 1.5, 1, 80)

		controller:TimerSimple(
			1.5 + buttonDelay,
			function()
				isMoving = false
				elevator:EmitSound("npc/metropolice/vo/allrightyoucango.wav")
			end
		)
		return true
	end

	for i, v in ipairs(buttons) do
		v.OnPressed = function(ent, activator)
			if isMoving or targetFloor == i then
				ent:EmitSound("buttons/button8.wav")
				return
			end

			ent:EmitSound("buttons/button24.wav", 75)
			controller:TimerSimple(
				0.2,
				function()
					ent:EmitSound("npc/metropolice/vo/citizen.wav")
					controller:TimerSimple(
						1,
						function()
							ent:EmitSound("npc/metropolice/vo/apply.wav")
						end
					)
				end
			)
			activator.waitEnt = ent
			activator.waitForApply = function()
				if IsValid(controller) then
					ent:EmitSound(MoveTo(i) and "npc/metropolice/vo/copy.wav" or "buttons/button8.wav", 75)
				end
			end
		end
	end
	for i, v in ipairs(calls) do
		v.OnPressed = function(ent, activator)
			if isMoving or targetFloor == i then
				ent:EmitSound("buttons/button8.wav")
				return
			end

			ent:EmitSound("buttons/button24.wav", 75)
			controller:TimerSimple(
				0.2,
				function()
					ent:EmitSound("npc/metropolice/vo/citizen.wav")
					controller:TimerSimple(
						1,
						function()
							ent:EmitSound("npc/metropolice/vo/apply.wav")
						end
					)
				end
			)
			activator.waitEnt = ent
			activator.waitForApply = function()
				if IsValid(controller) then
					ent:EmitSound(MoveTo(i) and "npc/metropolice/vo/copy.wav" or "buttons/button8.wav", 75)
				end
			end
		end
	end
	for i, v in ipairs(paths) do
		v.OnPass = function(ent, activator)
			CheckFloor(i)
		end
	end
end

hook.Add("OnMapLogicInitialized", "pb_v2_metropolice_elevator", Init)
