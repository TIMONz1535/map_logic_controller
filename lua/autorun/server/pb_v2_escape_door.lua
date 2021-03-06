-- © 2022 PostBellum HL2 RP. All rights reserved.

local function Init(controller, mapName)
	if mapName ~= "rp_pb_industrial17_v2" then
		return
	end

	local buttonDelay = 5
	local light = controller:GetMetaTarget("secret_light1")
	local lamp = controller:GetMetaTarget("secret_light1_models")
	local level1 = controller:GetMetaTarget("secret_button_01")
	local level2 = controller:GetMetaTarget("secret_button_02")
	local button = controller:GetMetaTarget("secret_button_03")
	local door = controller:GetMetaTarget("secret_door_01")

	level1:SetKeyValue("wait", buttonDelay)
	level2:SetKeyValue("wait", buttonDelay)
	button:SetKeyValue("wait", buttonDelay)
	door:DisableCombineUse()

	local lightState = true
	local isPressed1 = false
	local isPressed2 = false

	level1.OnOpen = function(ent, activator)
		isPressed1 = true
		controller:TimerSimple(
			0.5,
			function()
				if not isPressed1 then
					return
				end
				isPressed1 = false

				lightState = not lightState
				if lightState then
					light:Fire("TurnOn")
					lamp:Fire("Skin", "1")
				else
					light:Fire("TurnOff")
					lamp:Fire("Skin", "0")
				end
			end
		)

		if isPressed1 and isPressed2 then
			isPressed1 = false
			isPressed2 = false
			door:Fire("Open")
		end
	end
	level2.OnOpen = function(ent, activator)
		isPressed2 = true
		controller:TimerSimple(
			0.5,
			function()
				if not isPressed2 then
					return
				end
				isPressed2 = false

				lightState = not lightState
				if lightState then
					light:Fire("TurnOn")
					lamp:Fire("Skin", "1")
				else
					light:Fire("TurnOff")
					lamp:Fire("Skin", "0")
				end
			end
		)

		if isPressed1 and isPressed2 then
			isPressed1 = false
			isPressed2 = false
			door:Fire("Open")
		end
	end

	button.OnPressed = function(ent, activator)
		door:Fire("Open")
	end
end

hook.Add("OnMapLogicInitialized", "pb_v2_escape_door", Init)
