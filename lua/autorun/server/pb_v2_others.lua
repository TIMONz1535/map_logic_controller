-- luacheck: globals timer MAP_CONTROLLER_FUNC Clockwork LOGTYPE_URGENT cwCPPlug

local function Init(self, mapName)
	if mapName ~= "rp_pb_industrial17_v2" then
		return
	end

	local terms_no = self:GetMetaTarget("start_button_no")
	local nexus_comend = self:GetMetaTarget("nexus_curfew")
	local nexus_kk = self:GetMetaTarget("nexus_lockdowndeactivate")
	local nexus_judgement = self:GetMetaTarget("nexus_judeactivate")
	local nexus_gate = self:GetMetaTarget("nexus_globe_bulkhead_close_button")

	-- hack because entities has no name
	local rationDoor = ents.FindInSphere(Vector(-7983, 5913, 430), 0.01)[2]
	local cwuButton = ents.FindInSphere(Vector(-11035, 4434, 583), 0.01)[1]
	if rationDoor and rationDoor:GetClass() == "func_door" then
		rationDoor:SetName("ration_button")
	end
	if cwuButton and cwuButton:GetClass() == "func_button" then
		cwuButton:SetName("cwu_button")
	end
	self:CacheEntNames()

	local ration_button = self:GetMetaTarget("ration_button")
	local cwu_button = self:GetMetaTarget("cwu_button")

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
	ration_button.OnOpen = logGen("[MapLogic] %s активировал оповещение Выдачи Рационов!")
	ration_button.OnClose = logGen("[MapLogic] %s выключил оповещение Выдачи Рационов.")
	cwu_button.OnPressed = logGen("[MapLogic] %s активировал оповещение Офиса ГСР!")
end

hook.Add("OnMapLogicInitialized", "pb_v2_others", Init)
