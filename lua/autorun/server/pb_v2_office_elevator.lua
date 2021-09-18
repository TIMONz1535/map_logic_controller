-- luacheck: globals timer MAP_CONTROLLER_FUNC

MAP_CONTROLLER_FUNC:Push(
	function(self)
		local buttonDelay = 3
		local elevator = self:GetMetaTarget("office_elevator")
		local path1 = self:GetMetaTarget("office_elevator_path1")
		local path2 = self:GetMetaTarget("office_elevator_path2")
		local path3 = self:GetMetaTarget("office_elevator_path3")
		local button1 = self:GetMetaTarget("office_elevator_button1")
		local button2 = self:GetMetaTarget("office_elevator_button2")
		local button3 = self:GetMetaTarget("office_elevator_button3")
		local call1 = self:GetMetaTarget("office_elevator_call1")
		local call2 = self:GetMetaTarget("office_elevator_call2")
		local call3 = self:GetMetaTarget("office_elevator_call3")
		local gate = self:GetMetaTarget("office_elevator_gate")
		local door1 = self:GetMetaTarget("office_elevator_door1")
		local door2 = self:GetMetaTarget("office_elevator_door2")
		local door3 = self:GetMetaTarget("office_elevator_door3")

		button1:SetKeyValue("wait", buttonDelay)
		button2:SetKeyValue("wait", buttonDelay)
		button3:SetKeyValue("wait", buttonDelay)
		call1:SetKeyValue("wait", buttonDelay)
		call2:SetKeyValue("wait", buttonDelay)
		call3:SetKeyValue("wait", buttonDelay)
		elevator:SetKeyValue("startspeed", 50)
		door1:DisableCombineUse()
		door2:DisableCombineUse()
		door3:DisableCombineUse()

		gate:Fire("SetAnimation", "open")
		door1:Fire("Open")

		local isMoving = false
		local targetFloor = 1

		local function moveTo(floor)
			if isMoving or targetFloor == floor then
				return false
			end
			isMoving = true

			gate:Fire("SetAnimation", "close")
			door1:Fire("Close")
			door2:Fire("Close")
			door3:Fire("Close")

			if targetFloor < floor then
				elevator:Fire("StartForward", nil, 1.5)
			else
				elevator:Fire("StartBackward", nil, 1.5)
			end
			targetFloor = floor
			return true
		end

		local function checkFloor(floor)
			if targetFloor ~= floor then
				return false
			end
			elevator:Fire("Stop")

			if floor == 1 then
				door1:Fire("Open", nil, 1)
			elseif floor == 2 then
				door2:Fire("Open", nil, 1)
			else
				door3:Fire("Open", nil, 1)
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

		button1.OnPressed = moveToGen(1)
		button2.OnPressed = moveToGen(2)
		button3.OnPressed = moveToGen(3)
		call1.OnPressed = moveToGen(1)
		call2.OnPressed = moveToGen(2)
		call3.OnPressed = moveToGen(3)

		path1.OnPass = function(ent, activator)
			checkFloor(1)
		end
		path2.OnPass = function(ent, activator)
			checkFloor(2)
		end
		path3.OnPass = function(ent, activator)
			checkFloor(3)
		end
	end
)
