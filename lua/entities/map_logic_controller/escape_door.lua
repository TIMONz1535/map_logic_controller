-- luacheck: globals timer MAP_CONTROLLER_FUNC

MAP_CONTROLLER_FUNC:Push(
	function(self)
		local buttonDelay = 5
		local light = self:GetMetaTarget("secret_light1")
		local lamp = self:GetMetaTarget("secret_light1_models")
		local level1 = self:GetMetaTarget("secret_button_01")
		local level2 = self:GetMetaTarget("secret_button_02")
		local button = self:GetMetaTarget("secret_button_03")
		local door = self:GetMetaTarget("secret_door_01")

		level1:SetKeyValue("wait", buttonDelay)
		level2:SetKeyValue("wait", buttonDelay)
		button:SetKeyValue("wait", buttonDelay)

		local isPressed1 = false
		local isPressed2 = false
		local lightState = false

		level1.OnOpen = function(ent, activator)
			lightState = not lightState
			if lightState then
				light:Fire("TurnOn")
				lamp:Fire("Skin", "1")
			else
				light:Fire("TurnOff")
				lamp:Fire("Skin", "0")
			end

			isPressed1 = true
			timer.Simple(
				0.5,
				function()
					isPressed1 = false
				end
			)

			if isPressed1 and isPressed2 then
				door:Fire("Unlock")
				door:Fire("Open")
			end
		end
		level2.OnOpen = function(ent, activator)
			lightState = not lightState
			if lightState then
				light:Fire("TurnOn")
				lamp:Fire("Skin", "1")
			else
				light:Fire("TurnOff")
				lamp:Fire("Skin", "0")
			end

			isPressed2 = true
			timer.Simple(
				0.5,
				function()
					isPressed2 = false
				end
			)

			if isPressed1 and isPressed2 then
				door:Fire("Unlock")
				door:Fire("Open")
			end
		end

		button.OnPressed = function(ent, activator)
			door:Fire("Unlock")
			door:Fire("Open")
		end

		door.OnClose = function(ent, activator)
			ent:Fire("Lock")
		end
	end
)
