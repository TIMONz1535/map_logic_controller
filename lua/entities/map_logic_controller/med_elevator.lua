-- luacheck: globals timer MAP_CONTROLLER_FUNC

MAP_CONTROLLER_FUNC:Push(
	function(self)
		local buttonDelay = 3
		local elevator = self:GetMetaTarget("med_elevator")
		local button = self:GetMetaTarget("med_elevator_button")
		local call1 = self:GetMetaTarget("med_elevator_call1")
		local call2 = self:GetMetaTarget("med_elevator_call2")
		local gate = self:GetMetaTarget("office_elevator_gate")
		local door1 = self:GetMetaTarget("med_elevator_door1")
		local door2 = self:GetMetaTarget("med_elevator_door2")

		button:SetKeyValue("wait", buttonDelay)
		call1:SetKeyValue("wait", buttonDelay)
		call2:SetKeyValue("wait", buttonDelay)

		local isMoving = false
		local targetFloor = true

		local function moveTo(floor)
			if isMoving or targetFloor == floor then
				return false
			end
			isMoving = true

			gate:Fire("SetAnimation", "close")
			door1:Fire("Close")
			door2:Fire("Close")

			elevator:Fire("Toggle", nil, 1)
			targetFloor = floor
			return true
		end

		local function checkFloor(floor)
			elevator:Fire("Stop", nil, 0)

			if floor then
				door1:Fire("Open", 1)
			else
				door2:Fire("Open", 1)
			end
			gate:Fire("SetAnimation", "open", 1.5)

			timer.Simple(
				buttonDelay,
				function()
					isMoving = false
				end
			)
			return true
		end

		local function moveToGen(floor)
			return function(ent, activator)
				if moveTo(floor) then
					ent:EmitSound("buttons/button24.wav", 75)
				else
					ent:EmitSound("buttons/button8.wav", 75)
				end
			end
		end

		button.OnPressed = moveToGen(not targetFloor)
		call1.OnPressed = moveToGen(true)
		call2.OnPressed = moveToGen(false)

		elevator.OnFullyOpen = function(ent, activator)
			checkFloor(false)
		end
		elevator.OnFullyClosed = function(ent, activator)
			checkFloor(true)
		end
	end
)
