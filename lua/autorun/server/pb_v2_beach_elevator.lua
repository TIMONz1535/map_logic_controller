-- luacheck: globals timer MAP_CONTROLLER_FUNC

local function Init(self, mapName)
	if mapName ~= "rp_pb_industrial17_v2" then
		return
	end

	local buttonDelay = 3
	local elevator = self:GetMetaTarget("beach_elevator")
	local path1 = self:GetMetaTarget("beach_elevator_path1")
	local path2 = self:GetMetaTarget("beach_elevator_path2")
	local path3 = self:GetMetaTarget("beach_elevator_path3")
	local path4 = self:GetMetaTarget("beach_elevator_path4")
	local button1 = self:GetMetaTarget("beach_elevator_button1")
	local button2 = self:GetMetaTarget("beach_elevator_button2")
	local button3 = self:GetMetaTarget("beach_elevator_button3")
	local button4 = self:GetMetaTarget("beach_elevator_button4")
	local call1 = self:GetMetaTarget("beach_elevator_call1")
	local call2 = self:GetMetaTarget("beach_elevator_call2")
	local call3 = self:GetMetaTarget("beach_elevator_call3")
	local call4 = self:GetMetaTarget("beach_elevator_call4")

	button1:SetKeyValue("wait", buttonDelay)
	button2:SetKeyValue("wait", buttonDelay)
	button3:SetKeyValue("wait", buttonDelay)
	button4:SetKeyValue("wait", buttonDelay)
	call1:SetKeyValue("wait", buttonDelay)
	call2:SetKeyValue("wait", buttonDelay)
	call3:SetKeyValue("wait", buttonDelay)
	call4:SetKeyValue("wait", buttonDelay)
	elevator:SetKeyValue("startspeed", 40)

	local isMoving = false
	local targetFloor = 1

	local function moveTo(floor)
		if isMoving or targetFloor == floor then
			return false
		end
		isMoving = true

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
	button4.OnPressed = moveToGen(4)
	call1.OnPressed = moveToGen(1)
	call2.OnPressed = moveToGen(2)
	call3.OnPressed = moveToGen(3)
	call4.OnPressed = moveToGen(4)

	path1.OnPass = function(ent, activator)
		checkFloor(1)
	end
	path2.OnPass = function(ent, activator)
		checkFloor(2)
	end
	path3.OnPass = function(ent, activator)
		checkFloor(3)
	end
	path4.OnPass = function(ent, activator)
		checkFloor(4)
	end
end

hook.Add("OnMapLogicInitialized", "pb_v2_beach_elevator", Init)
