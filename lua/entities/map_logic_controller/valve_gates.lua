-- luacheck: globals timer MAP_CONTROLLER_FUNC

MAP_CONTROLLER_FUNC:Push(
	function(self)
		do
			local valve1 = self:GetMetaTarget("gate1_wheel")
			local valve2 = self:GetMetaTarget("gate1_wheel2")
			local move = self:GetMetaTarget("door_lock1")

			valve1.Position = function(ent, activator, value)
				move:Fire("SetPosition", value)
			end
			valve2.Position = function(ent, activator, value)
				move:Fire("SetPosition", value)
			end

			valve1.OnPressed = function(ent, activator)
				valve2:Fire("Lock")
			end
			valve2.OnPressed = function(ent, activator)
				valve1:Fire("Lock")
			end

			move.OnFullyClosed = function(ent, activator)
				valve1:Fire("Unlock", nil, 0.5)
				valve2:Fire("Unlock", nil, 0.5)
			end
		end
		do
			local valve1 = self:GetMetaTarget("gate3_wheel")
			local valve2 = self:GetMetaTarget("gate3_wheel2")
			local move = self:GetMetaTarget("door_lock2_2")

			valve1.Position = function(ent, activator, value)
				move:Fire("SetPosition", value)
			end
			valve2.Position = function(ent, activator, value)
				move:Fire("SetPosition", value)
			end

			valve1.OnPressed = function(ent, activator)
				valve2:Fire("Lock")
			end
			valve2.OnPressed = function(ent, activator)
				valve1:Fire("Lock")
			end

			move.OnFullyClosed = function(ent, activator)
				valve1:Fire("Unlock", nil, 0.5)
				valve2:Fire("Unlock", nil, 0.5)
			end
		end
	end
)
