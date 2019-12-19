-- luacheck: globals timer MAP_CONTROLLER_FUNC FL_ATCONTROLS CurTime math

MAP_CONTROLLER_FUNC:Push(
	function(self)
		local valve1 = self:GetMetaTarget("gate1_wheel")
		local valve2 = self:GetMetaTarget("gate1_wheel2")
		local move = self:GetMetaTarget("door_lock1")

		local valve_distance = 210 -- deg
		local valve_speed = 35 -- deg/sec
		local valve_returnspeed = 10 -- deg/sec
		local move_distance = 148

		valve1:SetKeyValue("distance", valve_distance)
		valve1:SetKeyValue("speed", valve_speed)
		valve1:SetKeyValue("returnspeed", valve_returnspeed)

		-- SetSpeed SetPosition

		local movePosition = 0
		local rotateActTime = 0
		valve1.OnPressed = function(ent, activator)
			local rotateDuration = CurTime() - rotateActTime
			local rotateDelta = (rotateDuration * valve_returnspeed) / valve_distance
			movePosition = math.Clamp(movePosition - rotateDelta, 0, 1)
			rotateActTime = CurTime()

			move:Fire("SetPositionImmediately", movePosition)
			move:Fire("Open")
		end
		valve1.OnUnpressed = function(ent, activator)
			local rotateDuration = CurTime() - rotateActTime
			local rotateDelta = (rotateDuration * valve_speed) / valve_distance
			movePosition = math.Clamp(movePosition + rotateDelta, 0, 1)
			rotateActTime = CurTime()

			move:Fire("SetPositionImmediately", movePosition)
			move:Fire("Close")
		end
	end
)
