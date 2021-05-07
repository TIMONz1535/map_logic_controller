-- luacheck: globals timer MAP_CONTROLLER_FUNC FL_ATCONTROLS Clockwork LOGTYPE_URGENT cwCPPlug

MAP_CONTROLLER_FUNC:Push(
	function(self)
		local terms_no = self:GetMetaTarget("start_button_no")
		local nexus_comend = self:GetMetaTarget("nexus_curfew")
		local nexus_kk = self:GetMetaTarget("nexus_lockdowndeactivate")
		local nexus_judgement = self:GetMetaTarget("nexus_judeactivate")
		local nexus_gate = self:GetMetaTarget("nexus_globe_bulkhead_close_button")

		terms_no.OnPressed = function(ent, activator)
			if activator:IsPlayer() then
				activator:Kick("Вы ответили неправильно!")
			end
		end

		local function logGen(message)
			return function(ent, activator)
				local name = activator:IsPlayer() and "Игрок " .. activator:Name() or "Нечто " .. tostring(activator)
				local text = message:format(name)
				Clockwork.kernel:PrintLog(LOGTYPE_URGENT, text)
				for _, v in ipairs(cwCPPlug:GetAdminListeners()) do
					Clockwork.player:Notify(v, text)
				end
			end
		end

		nexus_comend.OnIn = logGen("[MapLogic] %s активировал Комендатский час!")
		nexus_comend.OnOut = logGen("[MapLogic] %s выключил Комендатский час.")
		nexus_kk.OnIn = logGen("[MapLogic] %s активировал Красный код!")
		nexus_kk.OnOut = logGen("[MapLogic] %s выключил Красный код.")
		nexus_judgement.OnIn = logGen("[MapLogic] %s активировал Судебное разбирательство отменено!")
		nexus_judgement.OnOut = logGen("[MapLogic] %s выключил Судебное разбирательство отменено.")
		nexus_gate.OnIn = logGen("[MapLogic] %s открыл Южные ворота!")
		nexus_gate.OnOut = logGen("[MapLogic] %s закрыл Южные ворота.")
	end
)
