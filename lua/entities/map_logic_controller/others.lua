-- luacheck: globals timer MAP_CONTROLLER_FUNC FL_ATCONTROLS

MAP_CONTROLLER_FUNC:Push(
	function(self)
		local terms_no = self:GetMetaTarget("start_button_no")

		terms_no.OnPressed = function(ent, activator)
			if activator:IsPlayer() then
				activator:Kick("Вы ответили неправильно!")
			end
		end
	end
)
